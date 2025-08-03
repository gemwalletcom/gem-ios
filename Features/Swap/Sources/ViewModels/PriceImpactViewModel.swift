// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import BigInt
import SwiftUI
import Style
import GemstonePrimitives
import Formatters

struct PriceImpactViewModel {
    let fromAssetPrice: AssetPriceValue
    let fromValue: String
    let toAssetPrice: AssetPriceValue
    let toValue: String

    private let swapConfig = GemstoneConfig.shared.getSwapConfig()
    private let valueFormatter = ValueFormatter(style: .full)
    private let percentFormatter = CurrencyFormatter.percent

    init(fromAssetPrice: AssetPriceValue, fromValue: String, toAssetPrice: AssetPriceValue, toValue: String) {
        self.fromAssetPrice = fromAssetPrice
        self.fromValue = fromValue
        self.toAssetPrice = toAssetPrice
        self.toValue = toValue
    }

    var showPriceImpactWarning: Bool { isHighPriceImpact }
    var highImpactWarningTitle: String {
        Localized.Swap.PriceImpactWarning.title
    }
    var highImpactWarningDescription: String? {
        guard let priceImpactText else { return nil }
        return Localized.Swap.PriceImpactWarning.description(priceImpactText, fromAssetPrice.asset.symbol)
    }

    var priceImpactTitle: String { Localized.Swap.priceImpact }
    var value: PriceImpactValue? { rawImpactPercentage.flatMap(evaluatePriceImpactValue) }

    var priceImpactText: String? {
        priceImpactPercentage.flatMap { CurrencyFormatter.percentSignLess.string($0) }
    }

    var priceImpactStyle: TextStyle {
        let color = switch value?.type {
        case .low, nil: Colors.secondaryText
        case .medium: Colors.orange
        case .high: Colors.red
        case .positive: Colors.green
        }

        return TextStyle(
            font: .callout,
            color: color
        )
    }
}

// MARK: - Private

extension PriceImpactViewModel {
    private var priceImpactPercentage: Double? { rawImpactPercentage.map(abs) }

    private var isHighPriceImpact: Bool {
        guard let priceImpactPercentage else { return false }
        return priceImpactPercentage >= Double(swapConfig.highPriceImpactPercent)
    }

    private var rawImpactPercentage: Double? {
        guard
            let fromAmount = getSwapAmount(value: fromValue, decimals: fromAssetPrice.asset.decimals.asInt),
            let toAmount = getSwapAmount(value: toValue, decimals: toAssetPrice.asset.decimals.asInt),
            let fromValue = assetFiatValue(value: fromAmount, price: fromAssetPrice.price?.price),
            let toValue = assetFiatValue(value: toAmount, price: toAssetPrice.price?.price)
        else {
            return nil
        }

        return calculatePriceImpact(fromValue: fromValue, expectedValue: toValue)
    }

    private func getSwapAmount(value: String, decimals: Int) -> Double? {
        guard
            let value = try? BigInt.from(string: value),
            let amount = try? valueFormatter.double(from: value, decimals: decimals)
        else {
            return nil
        }
        return amount
    }

    private func assetFiatValue(value: Double, price: Double?) -> Double? {
        guard let price else {
            return nil
        }
        return value * price
    }

    private func evaluatePriceImpactValue(priceImpact: Double) -> PriceImpactValue? {
        let priceImpactPercentage = percentFormatter.string(priceImpact)

        switch priceImpact.rounded(toPlaces: 2) * -1 {
        case ..<0:
            return PriceImpactValue(type: .positive, value: priceImpactPercentage)
        case 0...1:
            return PriceImpactValue(type: .low, value: priceImpactPercentage)
        case 1...5:
            return PriceImpactValue(type: .medium, value: priceImpactPercentage)
        default:
            return PriceImpactValue(type: .high, value: priceImpactPercentage)
        }
    }

    private func calculatePriceImpact(fromValue: Double, expectedValue: Double) -> Double {
        guard fromValue > 0 else { return .zero }
        return ((expectedValue / fromValue) - 1 ) * 100
    }
}
