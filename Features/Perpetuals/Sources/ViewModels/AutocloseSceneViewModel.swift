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

    var takeProfitInputModel: InputValidationViewModel

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
        self.takeProfitInputModel = InputValidationViewModel(mode: .manual, validators: [validator])

        if let takeProfitPrice = position.position.takeProfit?.price {
            takeProfitInputModel.text = formatPriceForInput(takeProfitPrice)
        }
    }

    var takeProfit: String {
        takeProfitInputModel.text
    }

    var takeProfitPrice: Double? {
        currencyFormatter.double(from: takeProfit)
    }

    public var doneTitle: String { Localized.Common.done }
    var title: String { "Auto close" }
    var targetPricePlaceholder: String { "Target price" } // TODO: Localized.Perpetual.targetPrice
    var takeProfitTitle: String { "Take profit" } // TODO: Localized.Perpetual.takeProfit
    var expectedProfitTitle: String { "Expected profit" } // TODO: Localized.Perpetual.expectedProfit

    var expectedProfitPercent: Double {
        guard let entryPrice = position.position.entryPrice, entryPrice > 0,
              let takeProfitValue = takeProfitPrice, takeProfitValue > 0,
              position.position.marginAmount > 0
        else {
            return 0
        }
        let size = position.position.size
        let profit = (takeProfitValue - entryPrice) * abs(size)
        return (profit / position.position.marginAmount) * 100
    }

    var expectedProfitText: String {
        guard let entryPrice = position.position.entryPrice, entryPrice > 0,
              let takeProfitValue = takeProfitPrice, takeProfitValue > 0
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
        guard let entryPrice = position.position.entryPrice, entryPrice > 0,
              let takeProfitValue = takeProfitPrice, takeProfitValue > 0
        else {
            return Colors.secondaryText
        }
        let size = position.position.size
        let profit = (takeProfitValue - entryPrice) * abs(size)

        return profit >= 0 ? Colors.green : Colors.red
    }

    var entryPriceTitle: String { "Entry Price" } // TODO: Localized.Perpetual.entryPrice
    var entryPriceText: String {
        position.position.entryPrice.map { currencyFormatter.string($0) } ?? "-"
    }

    var markPriceTitle: String { "Mark Price" } // TODO: Localized.Perpetual.markPrice
    var markPriceText: String {
        currencyFormatter.string(position.perpetual.price)
    }

    var buttonType: ButtonType {
        .primary()
    }
}

// MARK: - Private

extension AutocloseSceneViewModel {
    private func formatPriceForInput(_ price: Double) -> String {
        priceFormatter.formatPriceForInput(price)
    }
}

// MARK: - Actions

extension AutocloseSceneViewModel {
    func onSelectConfirmButton() {
        // TODO: - update
        guard takeProfitInputModel.update() else {
            return
        }

        guard let takeProfitPrice = takeProfitPrice else {
            return
        }

        let price = priceFormatter.formatPrice(
            provider: position.perpetual.provider,
            takeProfitPrice,
            decimals: Int(position.asset.decimals)
        )

        let size = priceFormatter.formatPrice(
            provider: position.perpetual.provider,
            position.position.size,
            decimals: Int(position.asset.decimals)
        )

        guard let assetIndex = Int32(position.perpetual.identifier) else {
            return
        }

        let data = AutocloseConfirmData(
            direction: position.position.direction,
            baseAsset: Asset.hyperliquidUSDC(),
            assetIndex: assetIndex,
            price: price,
            size: size
        )

        let transferData = TransferData(
            type: .perpetual(position.asset, .autoclose(data)),
            recipientData: RecipientData.hyperliquid(),
            value: .zero,
            canChangeValue: false
        )

        onTransferAction?(transferData)
    }
}
