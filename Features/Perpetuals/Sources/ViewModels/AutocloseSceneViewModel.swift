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
    var focusField: AutocloseScene.Field?

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

    var title: String { "Auto close" }
    var targetPriceTitle: String { "Target price" }
    var takeProfitTitle: String { "Take profit" }
    var expectedProfitTitle: String { "Expected profit" }

    var expectedProfitPercent: Double {
        guard let profit = calculatedProfit,
              let entryPrice = position.position.entryPrice
        else {
            return 0
        }
        let initialMargin = abs(position.position.size) * entryPrice / Double(position.position.leverage)
        return (profit / initialMargin) * 100
    }

    var expectedProfitText: String {
        guard let profit = calculatedProfit else { return "-" }
        let profitAmount = currencyFormatter.string(abs(profit))
        let percentText = percentFormatter.string(expectedProfitPercent)
        return profit >= 0 ? "+\(profitAmount) (\(percentText))" : "-\(profitAmount) (\(percentText))"
    }

    var expectedProfitColor: Color {
        guard let profit = calculatedProfit else { return Colors.secondaryText }
        return profit >= 0 ? Colors.green : Colors.red
    }

    var entryPriceTitle: String { "Entry Price" }
    var entryPriceText: String {
        position.position.entryPrice.map { currencyFormatter.string($0) } ?? "-"
    }

    var marketPriceTitle: String { "Market Price" }
    var marketPriceText: String {
        currencyFormatter.string(position.perpetual.price)
    }

    var buttonType: ButtonType {
        if hasTakeProfit || takeProfitPrice == nil {
            return .primary(.disabled)
        }
        return .primary()
    }

    var showButton: Bool {
        !takeProfit.isEmpty
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
}

// MARK: - Actions

extension AutocloseSceneViewModel {
    func onDone() {
        focusField = nil
    }

    func onSelectConfirm() {
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
        let tpslData = TPSLOrderData(
            direction: position.position.direction,
            takeProfit: price,
            stopLoss: nil,
            size: .zero
        )
        let data = PerpetualModifyConfirmData(
            baseAsset: Asset.hyperliquidUSDC(),
            assetIndex: assetIndex,
            modifyTypes: [.tpsl(tpslData)]
        )

        let transferData = TransferData(
            type: .perpetual(position.asset, .modify(data)),
            recipientData: RecipientData.hyperliquid(),
            value: .zero,
            canChangeValue: false
        )

        onTransferAction?(transferData)
    }

    func onSelectCancel() {
        guard let orderId = takeProfitOrderId,
              let assetIndex = Int32(position.perpetual.identifier) else {
            return
        }

        let cancelOrder = CancelOrderData(assetIndex: assetIndex, orderId: orderId)
        let data = PerpetualModifyConfirmData(
            baseAsset: Asset.hyperliquidUSDC(),
            assetIndex: assetIndex,
            modifyTypes: [.cancel([cancelOrder])]
        )

        let transferData = TransferData(
            type: .perpetual(position.asset, .modify(data)),
            recipientData: RecipientData.hyperliquid(),
            value: .zero,
            canChangeValue: false
        )

        onTransferAction?(transferData)
    }

    func onSelectPercent(_ percent: Int) {
        guard let entryPrice = position.position.entryPrice else { return }

        let percentMultiplier = Double(percent) / 100.0
        let priceChange = entryPrice * percentMultiplier

        let targetPrice = position.position.direction == .long
            ? entryPrice + priceChange
            : entryPrice - priceChange

        inputModel.text = priceFormatter.formatInputPrice(targetPrice, decimals: 2)
    }
}

// MARK: - Private

extension AutocloseSceneViewModel {
    private var calculatedProfit: Double? {
        guard let entryPrice = position.position.entryPrice,
              let takeProfitValue = takeProfitPrice
        else {
            return nil
        }
        return (takeProfitValue - entryPrice) * abs(position.position.size)
    }
}
