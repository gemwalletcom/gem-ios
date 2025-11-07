// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Preferences
import Components
import PriceAlertService
import Style
import Localization
import Formatters

@MainActor
@Observable
public final class SetPriceAlertViewModel {
    private let walletId: WalletId
    private let assetId: AssetId
    private let priceAlertService: PriceAlertService
    private let onComplete: StringAction
    private let preferences = Preferences.standard
    private let currencyFormatter = CurrencyFormatter(currencyCode: Preferences.standard.currency)

    var state: SetPriceAlertViewModelState
    let preselectedPercentages: [String] = ["5", "10", "15"]
    
    public init(
        walletId: WalletId,
        assetId: AssetId,
        priceAlertService: PriceAlertService,
        onComplete: StringAction
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.priceAlertService = priceAlertService
        self.onComplete = onComplete
        self.state = .init()
    }

    var assetRequest: AssetRequest {
        AssetRequest(
            walletId: walletId.id,
            assetId: assetId
        )
    }
    
    var showPercentagePreselectedPicker: Bool {
        state.type == .percentage
    }
    
    var alertDirectionTitle: String {
        switch (state.type, state.alertDirection) {
        case (.price, .up): Localized.PriceAlerts.SetAlert.priceOver
        case (.price, .down): Localized.PriceAlerts.SetAlert.priceUnder
        case (.price, .none): Localized.PriceAlerts.SetAlert.setTargetPrice
        case (.percentage, .up): Localized.PriceAlerts.SetAlert.priceIncreasesBy
        case (.percentage, .down): Localized.PriceAlerts.SetAlert.priceDecreasesBy
        case (.percentage, .none): .empty
        }
    }
    
    var isEnabledConfirmButton: Bool {
        guard !state.amount.isEmpty,
              currencyFormatter.double(from: state.amount) != .zero,
              state.alertDirection != nil
        else {
            return false
        }
        return true
    }
    
    var confirmButtonState: ButtonState {
        isEnabledConfirmButton ? .normal : .disabled
    }

    func currencyInputConfig(for assetData: AssetData) -> any CurrencyInputConfigurable {
        SetPriceAlertCurrencyInputConfig(
            type: state.type,
            alertDirection: state.alertDirection,
            assetData: assetData,
            formatter: currencyFormatter,
            onTapActionButton: toggleAlertDirection
        )
    }
    
    func onChangeAlertType(_: SetPriceAlertType, type: SetPriceAlertType) {
        state.type = type
    }
    
    func setAlertDirection(for price: Price?) {
        switch state.type {
        case .price:
            state.alertDirection = priceAlertDirection(
                amount: state.amount,
                price: price?.price
            )
        case .percentage:
            break
        }
    }
    
    // MARK: - Private
    
    private var amountValue: Double? {
        currencyFormatter.double(from: state.amount)
    }
    
    private var completeMessage: String {
        guard let amountValue else { return .empty }
        let amount: String = {
            switch state.type {
            case .price: currencyFormatter.string(amountValue)
            case .percentage: "\(amountValue)%"
            }
        }()
        let message = [alertDirectionTitle.lowercased(), amount].joined(separator: " ")
        return Localized.PriceAlerts.addedFor(message)
    }
    
    private func priceAlertDirection(
        amount: String,
        price: Double?
    ) -> PriceAlertDirection? {
        guard let price,
              let priceValue = currencyFormatter.normalizedDouble(from: price),
              let amountValue = currencyFormatter.double(from: amount)
        else {
            return nil
        }
        
        switch amountValue {
        case _ where amountValue > priceValue:
            return .up
        case _ where amountValue < priceValue:
            return .down
        default:
            return nil
        }
    }
    
    private func priceAlert() -> PriceAlert {
        let (price, pricePercentChange): (Double?, Double?) = {
            switch state.type {
            case .price: (amountValue, nil)
            case .percentage: (nil, amountValue)
            }
        }()
        return PriceAlert(
            assetId: assetId,
            currency: preferences.currency,
            price: price,
            pricePercentChange: pricePercentChange,
            priceDirection: state.alertDirection,
            lastNotifiedAt: .none
        )
    }
    
    private func toggleAlertDirection() {
        switch state.alertDirection {
        case .up: state.alertDirection = .down
        case .down: state.alertDirection = .up
        default: break
        }
    }
}

// MARK: - Business logic

extension SetPriceAlertViewModel {
    func setPriceAlert() async {
        do {
            await updateNotificationsIfNeeded()
            onComplete?(completeMessage)
            try await priceAlertService.add(priceAlert: priceAlert())
        } catch {
            #debugLog("Set price alert error: \(error.localizedDescription)")
        }
    }
    
    private func updateNotificationsIfNeeded() async {
        guard !preferences.isPushNotificationsEnabled else { return }
        
        do {
            preferences.isPushNotificationsEnabled = try await requestPermissions()
        } catch {
            #debugLog("pushesUpdate error: \(error)")
        }
    }
    
    private func requestPermissions() async throws -> Bool {
        try await priceAlertService.requestPermissions()
    }
}
