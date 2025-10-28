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
import Components

@Observable
@MainActor
public final class AutocloseSceneViewModel {
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter: CurrencyFormatter
    private let priceFormatter: PerpetualPriceFormatter
    private let position: PerpetualPositionData
    private let onTransferAction: TransferDataAction
    private let estimator: AutocloseEstimator

    var takeProfitInput: InputValidationViewModel
    var stopLossInput: InputValidationViewModel

    var focusField: AutocloseScene.Field?

    public init(position: PerpetualPositionData, onTransferAction: TransferDataAction = nil) {
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
        self.percentFormatter = CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)
        self.priceFormatter = PerpetualPriceFormatter()

        self.position = position
        self.onTransferAction = onTransferAction

        self.estimator = AutocloseEstimator(
            entryPrice: position.position.entryPrice ?? .zero,
            positionSize: position.position.size,
            direction: position.position.direction,
            leverage: position.position.leverage
        )

        self.takeProfitInput = InputValidationViewModel(
            mode: .manual,
            validators: [
                AutocloseValidator(
                    type: .takeProfit,
                    marketPrice: position.perpetual.price
                )
            ]
        )

        self.stopLossInput = InputValidationViewModel(
            mode: .manual,
            validators: [
                AutocloseValidator(
                    type: .stopLoss,
                    marketPrice: position.perpetual.price
                )
            ]
        )

        if let price = position.position.takeProfit?.price {
            takeProfitInput.text = priceFormatter.formatInputPrice(price)
        }

        if let price = position.position.stopLoss?.price {
            stopLossInput.text = priceFormatter.formatInputPrice(price)
        }
    }

    var title: String { "Auto Close" }

    var triggerPriceTitle: String { "Trigger price" }

    var takeProfitTitle: String { "Take profit" }
    var stopLossTitle: String { "Stop Loss" }

    var estimatedPNL: String { "Estimated PNL" }

    var entryPriceTitle: String { "Entry Price" }
    var entryPriceText: String {
        position.position.entryPrice.map { currencyFormatter.string($0) } ?? "-"
    }

    var marketPriceTitle: String { "Market Price" }
    var marketPriceText: String {
        currencyFormatter.string(position.perpetual.price)
    }

    var expectedProfitText: String {
        formatExpectedPnL(price: takeProfitPrice)
    }

    var expectedProfitColor: Color {
        colorForPnL(price: takeProfitPrice)
    }

    var expectedStopLossText: String {
        formatExpectedPnL(price: stopLossPrice)
    }

    var expectedStopLossColor: Color {
        colorForPnL(price: stopLossPrice)
    }

    var takeProfitOrderId: UInt64? {
        guard let orderId = position.position.takeProfit?.order_id else { return nil }
        return UInt64(orderId)
    }

    var stopLossOrderId: UInt64? {
        guard let orderId = position.position.stopLoss?.order_id else { return nil }
        return UInt64(orderId)
    }
}

// MARK: - Actions

extension AutocloseSceneViewModel {
    func onDone() {
        focusField = nil
    }

    func onChangeFocusField(_ oldField: AutocloseScene.Field?, _ newField: AutocloseScene.Field?) {
        focusField = newField
    }

    func onSelectConfirm() {
        guard let assetIndex = Int32(position.perpetual.identifier) else { return }

        let builder = AutocloseModifyBuilder(position: position)

        let takeProfitField = AutocloseField(
            price: takeProfitPrice,
            originalPrice: position.position.takeProfit?.price,
            formattedPrice: takeProfitPrice.map { formatPrice($0) },
            isValid: !takeProfit.isEmpty && takeProfitInput.update(),
            orderId: takeProfitOrderId
        )

        let stopLossField = AutocloseField(
            price: stopLossPrice,
            originalPrice: position.position.stopLoss?.price,
            formattedPrice: stopLossPrice.map { formatPrice($0) },
            isValid: !stopLoss.isEmpty && stopLossInput.update(),
            orderId: stopLossOrderId
        )

        guard builder.hasChanges(takeProfit: takeProfitField, stopLoss: stopLossField) else { return }

        let modifyTypes = builder.build(
            assetIndex: assetIndex,
            takeProfit: takeProfitField,
            stopLoss: stopLossField
        )
        guard !modifyTypes.isEmpty else { return }

        let data = PerpetualModifyConfirmData(
            baseAsset: .hypercoreUSDC(),
            assetIndex: assetIndex,
            modifyTypes: modifyTypes
        )

        let transferData = TransferData(
            type: .perpetual(position.asset, .modify(data)),
            recipientData: RecipientData.hyperliquid(),
            value: .zero,
            canChangeValue: false
        )

        onTransferAction?(transferData)
    }

    private func formatPrice(_ price: Double) -> String {
        priceFormatter.formatPrice(
            provider: position.perpetual.provider,
            price,
            decimals: Int(position.asset.decimals)
        )
    }

    func onSelectPercent(_ percent: Int) {
        let type: TpslType = focusField == .takeProfit ? .takeProfit : .stopLoss
        let targetPrice = estimator.calculateTargetPriceFromROE(roePercent: percent, type: type)
        let inputModel = type == .takeProfit ? takeProfitInput : stopLossInput
        inputModel.text = priceFormatter.formatInputPrice(targetPrice, decimals: 2)
    }
}

// MARK: - Private

extension AutocloseSceneViewModel {
    private var takeProfit: String { takeProfitInput.text }
    private var takeProfitPrice: Double? { currencyFormatter.double(from: takeProfit) }

    private var stopLoss: String { stopLossInput.text }
    private var stopLossPrice: Double? { currencyFormatter.double(from: stopLoss) }

    private func formatExpectedPnL(price: Double?) -> String {
        guard let triggerPrice = price else { return "-" }
        let pnl = estimator.calculatePnL(triggerPrice: triggerPrice)
        let roe = estimator.calculateROE(triggerPrice: triggerPrice)

        let amount = currencyFormatter.string(abs(pnl))
        let percentText = percentFormatter.string(roe)
        let sign = pnl >= 0 ? "+" : "-"

        return "\(sign)\(amount) (\(percentText))"
    }

    private func colorForPnL(price: Double?) -> Color {
        guard let triggerPrice = price else { return Colors.secondaryText }
        let pnl = estimator.calculatePnL(triggerPrice: triggerPrice)
        return PriceChangeColor.color(for: pnl)
    }

}
