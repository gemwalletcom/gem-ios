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

    var input: AutocloseInput

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

        let takeProfitInput = InputValidationViewModel(
            mode: .manual,
            validators: [
                AutocloseValidator(
                    type: .takeProfit,
                    marketPrice: position.perpetual.price,
                    direction: position.position.direction
                )
            ]
        )

        let stopLossInput = InputValidationViewModel(
            mode: .manual,
            validators: [
                AutocloseValidator(
                    type: .stopLoss,
                    marketPrice: position.perpetual.price,
                    direction: position.position.direction
                )
            ]
        )

        if let price = position.position.takeProfit?.price {
            takeProfitInput.text = priceFormatter.formatInputPrice(price, szDecimals: position.asset.decimals.asInt)
        }

        if let price = position.position.stopLoss?.price {
            stopLossInput.text = priceFormatter.formatInputPrice(price, szDecimals: position.asset.decimals.asInt)
        }

        self.input = AutocloseInput(
            takeProfit: takeProfitInput,
            stopLoss: stopLossInput,
            focusField: nil
        )
    }

    var title: String { Localized.Perpetual.autoClose }

    var entryPriceTitle: String { Localized.Perpetual.entryPrice }
    var entryPriceText: String { position.position.entryPrice.map { currencyFormatter.string($0) } ?? "-" }

    var marketPriceTitle: String { Localized.Perpetual.marketPrice }
    var marketPriceText: String { currencyFormatter.string(position.perpetual.price) }

    var takeProfitModel: AutocloseViewModel { autocloseModel(type: .takeProfit, price: takeProfitPrice) }
    var stopLossModel: AutocloseViewModel { autocloseModel(type: .stopLoss, price: stopLossPrice) }

    var positionViewModel: PerpetualPositionViewModel { PerpetualPositionViewModel(position) }

    var confirmButtonType: ButtonType {
        let builder = AutocloseModifyBuilder(position: position)
        let isEnabled = builder.canBuild(takeProfit: takeProfitField, stopLoss: stopLossField)
        return .primary(isEnabled ? .normal : .disabled)
    }
}

// MARK: - Actions

extension AutocloseSceneViewModel {
    func onDone() {
        input.focusField = nil
    }

    func onChangeFocusField(_ oldField: AutocloseScene.Field?, _ newField: AutocloseScene.Field?) {
        input.focusField = newField
    }

    func onSelectConfirm() {
        input.update()

        guard let assetIndex = Int32(position.perpetual.identifier) else { return }

        let builder = AutocloseModifyBuilder(position: position)
        guard builder.canBuild(takeProfit: takeProfitField, stopLoss: stopLossField) else { return }

        let modifyTypes = builder.build(
            assetIndex: assetIndex,
            takeProfit: takeProfitField,
            stopLoss: stopLossField
        )

        let data = PerpetualModifyConfirmData(
            baseAsset: .hypercoreUSDC(),
            assetIndex: assetIndex,
            modifyTypes: modifyTypes,
            takeProfitOrderId: takeProfitOrderId,
            stopLossOrderId: stopLossOrderId
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
        guard let type = input.focusedType, let focused = input.focused else { return }

        let targetPrice = estimator.calculateTargetPriceFromROE(roePercent: percent, type: type)
        focused.text = priceFormatter.formatInputPrice(targetPrice, szDecimals: position.asset.decimals.asInt)
    }
}

// MARK: - Private

extension AutocloseSceneViewModel {
    private var takeProfitPrice: Double? { currencyFormatter.double(from: input.takeProfit.text)}
    private var stopLossPrice: Double? { currencyFormatter.double(from: input.stopLoss.text) }

    private var takeProfitField: AutocloseField {
        input.field(
            type: .takeProfit,
            price: takeProfitPrice,
            originalPrice: position.position.takeProfit?.price,
            formattedPrice: takeProfitPrice.map { formatPrice($0) },
            orderId: takeProfitOrderId
        )
    }

    private var stopLossField: AutocloseField {
        input.field(
            type: .stopLoss,
            price: stopLossPrice,
            originalPrice: position.position.stopLoss?.price,
            formattedPrice: stopLossPrice.map { formatPrice($0) },
            orderId: stopLossOrderId
        )
    }

    private func autocloseModel(type: TpslType, price: Double?) -> AutocloseViewModel {
        AutocloseViewModel(
            type: type,
            price: price,
            estimator: estimator,
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
    }

    private var takeProfitOrderId: UInt64? {
        if let orderId = position.position.takeProfit?.order_id {
            return UInt64(orderId)
        }
        return nil
    }

    private var stopLossOrderId: UInt64? {
        if let orderId = position.position.stopLoss?.order_id {
            return UInt64(orderId)
        }
        return nil
    }

    private func formatPrice(_ price: Double) -> String {
        priceFormatter.formatPrice(
            provider: position.perpetual.provider,
            price,
            decimals: Int(position.asset.decimals)
        )
    }
}
