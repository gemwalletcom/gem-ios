// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import BigInt

struct PriceImpactViewModel {
    let fromAssetData: AssetData
    let fromValue: String
    let toAssetData: AssetData
    let toValue: String
    
    var priceImpactTitle: String { Localized.Swap.priceImpact }
    
    private let valueFormatter = ValueFormatter(style: .full)
    private let percentFormatter = CurrencyFormatter(type: .percentSignLess)
    
    // MARK: - Public methods
    
    func type() -> PriceImpactType {
        guard
            let fromAmount = getSwapAmount(value: fromValue, decimals: fromAssetData.asset.decimals.asInt),
            let toAmount = getSwapAmount(value: toValue, decimals: toAssetData.asset.decimals.asInt),
            let fromValue = assetFiatValue(value: fromAmount, price: fromAssetData.price?.price),
            let toValue = assetFiatValue(value: toAmount, price: toAssetData.price?.price)
        else {
            return .none
        }
        let priceImpact = calculatePriceImpact(fromValue: fromValue, expectedValue: toValue)
        return evaluatePriceImpactType(priceImpact: priceImpact)
    }
    
    // MARK: - Private methods
    
    private func getSwapAmount(value: String, decimals: Int) -> Double? {
        guard
            let value = try? valueFormatter.inputNumber(from: value, decimals: decimals),
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
    
    private func evaluatePriceImpactType(priceImpact: Double?) -> PriceImpactType {
        guard let priceImpact else {
            return .none
        }
        let priceImpactPercentage = percentFormatter.string(abs(priceImpact))
        
        switch priceImpact.rounded(toPlaces: 2) {
        case ..<0:
            return .positive("+" + priceImpactPercentage)
        case 0...1:
            return .low("-" + priceImpactPercentage)
        case 1...5:
            return .medium("-" + priceImpactPercentage)
        default:
            return .high("-" + priceImpactPercentage)
        }
    }
    
    private func calculatePriceImpact(fromValue: Double, expectedValue: Double) -> Double? {
        guard fromValue > 0 else { return nil }
        return (1 - (expectedValue / fromValue)) * 100
    }
}
