// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import BigInt
import SwiftUI
import Style

struct PriceImpactViewModel {
    let fromAssetData: AssetData
    let fromValue: String
    let toAssetData: AssetData
    let toValue: String
    
    var priceImpactTitle: String { Localized.Swap.priceImpact }
    
    private let valueFormatter = ValueFormatter(style: .full)
    private let percentFormatter = CurrencyFormatter(type: .percent)
    
    // MARK: - Public methods
    
    func value() -> PriceImpactValue? {
        guard
            let fromAmount = getSwapAmount(value: fromValue, decimals: fromAssetData.asset.decimals.asInt),
            let toAmount = getSwapAmount(value: toValue, decimals: toAssetData.asset.decimals.asInt),
            let fromValue = assetFiatValue(value: fromAmount, price: fromAssetData.price?.price),
            let toValue = assetFiatValue(value: toAmount, price: toAssetData.price?.price)
        else {
            return nil
        }
        let priceImpact = calculatePriceImpact(fromValue: fromValue, expectedValue: toValue)
        return evaluatePriceImpactValue(priceImpact: priceImpact)
    }
    
    func priceImpactColor(for type: PriceImpactType) -> Color {
        switch type {
        case .low: Colors.black
        case .medium: Colors.orange
        case .high: Colors.red
        case .positive: Colors.green
        }
    }
    
    // MARK: - Private methods
    
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
            return nil
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
