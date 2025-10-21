// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import Localization
import Store
import PrimitivesComponents
import Style
import Validators
import SwiftUI

@Observable
@MainActor
public final class AutocloseSceneViewModel {
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter: CurrencyFormatter
    private let priceFormatter: PerpetualPriceFormatter
    private let position: PerpetualPositionData
    private let onTransferAction: TransferDataAction

    var inputModel: InputValidationViewModel

    public init(position: PerpetualPositionData, onTransferAction: TransferDataAction = nil) {
        self.position = position
        self.onTransferAction = onTransferAction
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
        self.percentFormatter = CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)
        self.priceFormatter = PerpetualPriceFormatter()

        let validator = TakeProfitValidator(
            marketPrice: position.perpetual.price,
            direction: position.position.direction
        )
        self.inputModel = InputValidationViewModel(mode: .manual, validators: [validator])

        if let price = position.position.takeProfit?.price {
            inputModel.text = priceFormatter.formatInputPrice(price)
        }
    }

    var takeProfit: String {
        inputModel.text
    }

    var takeProfitPrice: Double? {
        currencyFormatter.double(from: takeProfit)
    }

    public var doneTitle: String { Localized.Common.done }
    var title: String { "Auto close" }
    var targetPriceTitle: String { "Target price" }
    var takeProfitTitle: String { "Take profit" }
    var expectedProfitTitle: String { "Expected profit" }

    var expectedProfitPercent: Double {
        guard let entryPrice = position.position.entryPrice,
              let takeProfitValue = takeProfitPrice
        else {
            return 0
        }
        let size = position.position.size
        let profit = (takeProfitValue - entryPrice) * abs(size)
        return (profit / position.position.marginAmount) * 100
    }

    var expectedProfitText: String {
        guard let entryPrice = position.position.entryPrice,
              let takeProfitValue = takeProfitPrice
        else {
            return "-"
        }
        let size = position.position.size
        let profit = (takeProfitValue - entryPrice) * abs(size)
        let profitAmount = currencyFormatter.string(abs(profit))
        let percentText = percentFormatter.string(expectedProfitPercent)

        if profit >= 0 {
            return "+\(profitAmount) (\(percentText))"
        } else {
            return "-\(profitAmount) (\(percentText))"
        }
    }

    var expectedProfitColor: Color {
        guard let entryPrice = position.position.entryPrice,
              let takeProfitValue = takeProfitPrice
        else {
            return Colors.secondaryText
        }
        let size = position.position.size
        let profit = (takeProfitValue - entryPrice) * abs(size)

        return profit >= 0 ? Colors.green : Colors.red
    }

    var entryPriceTitle: String { "Entry Price" }
    var entryPriceText: String {
        position.position.entryPrice.map { currencyFormatter.string($0) } ?? "-"
    }

    var markPriceTitle: String { "Market Price" }
    var markPriceText: String {
        currencyFormatter.string(position.perpetual.price)
    }

    var buttonType: ButtonType {
        if hasTakeProfit || takeProfitPrice == nil {
            return .primary(.disabled)
        }
        return .primary()
    }

    var hasTakeProfit: Bool {
        position.position.takeProfit != nil
    }

    var takeProfitOrderId: UInt64? {
        guard let orderId = position.position.takeProfit?.order_id else { return nil }
        return UInt64(orderId)
    }

    var currentTakeProfitPrice: String {
        guard let takeProfit = position.position.takeProfit else { return "-" }
        return currencyFormatter.string(takeProfit.price)
    }

    /* TODO: - stop loss
     var hasStopLoss: Bool {
     position.position.stopLoss != nil
     }

     var stopLossOrderId: UInt64? {
         guard let orderId = position.position.stopLoss?.order_id else { return nil }
         return UInt64(orderId)
     }

     var currentStopLossPrice: String {
     guard let stopLoss = position.position.stopLoss else { return "-" }
     return currencyFormatter.string(stopLoss.price)
     }
     */
}

// MARK: - Actions

extension AutocloseSceneViewModel {
    func onSelectConfirm() {
        setTakeProfit()
    }

    func onSelectCancel() {
        cancelTakeProfit()
    }
}

// MARK: - Private

extension AutocloseSceneViewModel {
    private func setTakeProfit() {
        guard let takeProfitPrice = takeProfitPrice,
              let assetIndex = Int32(position.perpetual.identifier),
              inputModel.update()
        else {
            return
        }

        let price = priceFormatter.formatPrice(
            provider: position.perpetual.provider,
            takeProfitPrice,
            decimals: Int(position.asset.decimals)
        )
        let data = PerpetualModifyConfirmData(
            baseAsset: Asset.hyperliquidUSDC(),
            assetIndex: assetIndex,
            modifyType: .tp(
                direction: position.position.direction,
                price: price,
                size: .zero
            )
        )

        let transferData = TransferData(
            type: .perpetual(position.asset, .modify(data)),
            recipientData: RecipientData.hyperliquid(),
            value: .zero,
            canChangeValue: false
        )

        onTransferAction?(transferData)
    }

    private func cancelTakeProfit() {
        guard let orderId = takeProfitOrderId,
              let assetIndex = Int32(position.perpetual.identifier) else {
            return
        }

        let cancelOrder = CancelOrderData(assetIndex: assetIndex, orderId: orderId)
        let data = PerpetualModifyConfirmData(
            baseAsset: Asset.hyperliquidUSDC(),
            assetIndex: assetIndex,
            modifyType: .cancel(orders: [cancelOrder])
        )

        let transferData = TransferData(
            type: .perpetual(position.asset, .modify(data)),
            recipientData: RecipientData.hyperliquid(),
            value: .zero,
            canChangeValue: false
        )

        onTransferAction?(transferData)
    }
}
