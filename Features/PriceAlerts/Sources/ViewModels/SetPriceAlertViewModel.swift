// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Preferences
import Components
import PriceAlertService
import Style
import Localization

@MainActor
@Observable
public final class SetPriceAlertViewModel {
    private let wallet: Wallet
    private let assetId: String
    private let priceAlertService: PriceAlertService
    private let onComplete: VoidAction
    
    private let currencyFormatter = CurrencyFormatter(currencyCode: Preferences.standard.currency)
    private let valueFormatter = ValueFormatter(style: .short)

    var state: SetPriceAlertViewModelState
    let preselectedPercentages: [String] = ["5", "10", "15"]
    
    public init(
        wallet: Wallet,
        assetId: String,
        priceAlertService: PriceAlertService,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.assetId = assetId
        self.priceAlertService = priceAlertService
        self.onComplete = onComplete
        self.state = .init()
    }

    var assetRequest: AssetRequest {
        AssetRequest(
            walletId: wallet.id,
            assetId: assetId
        )
    }
    
    var showPercentagePreselectedPicker: Bool {
        state.type == .percentage
    }
    
    var alertDirectionTitle: String {
        switch (state.type, state.alertDirection) {
        case (.price, .up): "When price is over"
        case (.price, .down): "When price is under"
        case (.price, .none): "Set target price"
        case (.percentage, .up): "When price increases by"
        case (.percentage, .down): "When price decreases by"
        case (.percentage, .none): .empty
        }
    }
    
    var isEnabledConfirmButton: Bool {
        guard !state.amount.isEmpty,
              let _ = try? valueFormatter.number(amount: state.amount).doubleValue,
              state.alertDirection != nil
        else {
            return false
        }
        return true
    }
    
    var confirmButtonState: StateButtonStyle.State {
        isEnabledConfirmButton ? .normal : .disabled
    }

    func currencyInputConfig(for assetData: AssetData) -> any CurrencyInputConfigurable {
        SetPriceAlertCurrencyInputConfig(
            type: state.type,
            alertDirection: state.alertDirection,
            assetData: assetData,
            formatter: currencyFormatter,
            onTapActionButton: {
                switch self.state.alertDirection {
                case .up: self.state.alertDirection = .down
                case .down: self.state.alertDirection = .up
                default: break
                }
            }
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
    
    // MARK: - Private methods
    
    private func priceAlertDirection(
        amount: String,
        price: Double?
    ) -> PriceAlertDirection? {
        guard let price,
              let normalizedPrice = currencyFormatter.normalizedDouble(from: price),
              let targetAmount = try? valueFormatter.number(amount: amount).doubleValue,
              let normalizedAmount = currencyFormatter.normalizedDouble(from: targetAmount)
        else {
            return nil
        }
        
        switch normalizedAmount {
        case _ where normalizedAmount > normalizedPrice:
            return .up
        case _ where normalizedAmount < normalizedPrice:
            return .down
        default:
            return nil
        }
    }
    
    private func priceAlert() -> PriceAlert {
        let (price, pricePercentChange): (Double?, Double?) = {
            let doubleValue: Double? = try? valueFormatter.number(amount: state.amount).doubleValue
            switch state.type {
            case .price:
                return (doubleValue, nil)
            case .percentage:
                return (nil, doubleValue)
            }
        }()
        return PriceAlert(
            assetId: assetId,
            price: price,
            pricePercentChange: pricePercentChange,
            priceDirection: state.alertDirection
        )
    }
}

// MARK: - Business logic

extension SetPriceAlertViewModel {
    func setPriceAlert() async throws {
        try await priceAlertService.addPriceAlert(priceAlert: priceAlert())
        onComplete?()
    }
}
