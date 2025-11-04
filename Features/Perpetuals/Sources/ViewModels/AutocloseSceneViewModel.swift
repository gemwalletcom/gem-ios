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

    var positionViewModel: PerpetualPositionViewModel {
        PerpetualPositionViewModel(position)
    }

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
                    marketPrice: position.perpetual.price,
                    direction: position.position.direction
                )
            ]
        )

        self.stopLossInput = InputValidationViewModel(
            mode: .manual,
            validators: [
                AutocloseValidator(
                    type: .stopLoss,
                    marketPrice: position.perpetual.price,
                    direction: position.position.direction
                )
            ]
        )
    }

    var title: String { Localized.Perpetual.autoClose }

    var entryPriceTitle: String { Localized.Perpetual.entryPrice }
    var entryPriceText: String {
        position.position.entryPrice.map { currencyFormatter.string($0) } ?? "-"
    }

    var marketPriceTitle: String { Localized.Perpetual.marketPrice }
    var marketPriceText: String {
        currencyFormatter.string(position.perpetual.price)
    }

    var takeProfitModel: AutocloseViewModel {
        AutocloseViewModel(
            type: .takeProfit,
            price: takeProfitPrice,
            estimator: estimator,
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
    }

    var stopLossModel: AutocloseViewModel {
        AutocloseViewModel(
            type: .stopLoss,
            price: stopLossPrice,
            estimator: estimator,
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
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
    func onAppear() {
        if let price = position.position.takeProfit?.price {
            takeProfitInput.text = priceFormatter.formatInputPrice(price)
        }

        if let price = position.position.stopLoss?.price {
            stopLossInput.text = priceFormatter.formatInputPrice(price)
        }
    }

    func onDone() {
        focusField = nil
    }

    func onChangeFocusField(_ oldField: AutocloseScene.Field?, _ newField: AutocloseScene.Field?) {
        focusField = newField
    }

    func onSelectConfirm() {
        guard let assetIndex = Int32(position.perpetual.identifier) else { return }

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
        guard let focusField else { return }

        let (type, inputModel): (TpslType, InputValidationViewModel) = switch focusField {
        case .takeProfit: (.takeProfit, takeProfitInput)
        case .stopLoss: (.stopLoss, stopLossInput)
        }

        let targetPrice = estimator.calculateTargetPriceFromROE(roePercent: percent, type: type)
        inputModel.text = priceFormatter.formatInputPrice(targetPrice, decimals: 2)
    }
}

// MARK: - Private

extension AutocloseSceneViewModel {
    private var takeProfit: String { takeProfitInput.text }
    private var takeProfitPrice: Double? { currencyFormatter.double(from: takeProfit) }

    private var stopLoss: String { stopLossInput.text }
    private var stopLossPrice: Double? { currencyFormatter.double(from: stopLoss) }

    private func formatPrice(_ price: Double) -> String {
        priceFormatter.formatPrice(
            provider: position.perpetual.provider,
            price,
            decimals: Int(position.asset.decimals)
        )
    }
}
