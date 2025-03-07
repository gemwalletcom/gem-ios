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
    private let currencyFormatter = CurrencyFormatter(currencyCode: Preferences.standard.currency)
    private let valueFormatter = ValueFormatter(style: .short)

    var state: SetPriceAlertViewModelState
    
    public init(
        wallet: Wallet,
        assetId: String,
        priceAlertService: PriceAlertService
    ) {
        self.wallet = wallet
        self.assetId = assetId
        self.priceAlertService = priceAlertService
        self.state = .init()
    }

    var assetRequest: AssetRequest {
        AssetRequest(
            walletId: wallet.id,
            assetId: assetId
        )
    }
    
    var showPercentageAlertDirectionPicker: Bool {
        state.type == .percentage
    }
    
    var alertDirectionTitle: String {
        switch (state.type, state.alertDirection) {
        case (.price, .up): "If the price exceeds"
        case (.price, .down): "If the price drops below"
        case (.price, .none): "Set a target price"
        case (.percentage, .up): "If the price increases by"
        case (.percentage, .down): "If the price decreases by"
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
            assetData: assetData,
            formatter: currencyFormatter
        )
    }
    
    func setPrice(_ : AssetData?, asset: AssetData) {
        guard let price = asset.price?.price else {
            return
        }
        state.amount = currencyFormatter.string(decimal: Decimal(price))
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
    }
}
