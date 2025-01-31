// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

enum PriceImpactValue: Equatable {
    case none
    case low(String)
    case medium(String)
    case high(String)
    case positive(String)
}

struct PriceImpactViewModel {
    let fromAssetData: AssetData
    let toAssetData: AssetData
    
    var priceImpact: String { Localized.Swap.priceImpact }
    
    private let valueFormatter = ValueFormatter(style: .medium)
    private var percentFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }
    
    // MARK: - Public methods
    
    func priceImpactValue(fromValue: String, toValue: String) -> PriceImpactValue {
        guard
            let fromAmount = getSwapAmount(value: fromValue, decimals: fromAssetData.asset.decimals.asInt),
            let toAmount = getSwapAmount(value: toValue, decimals: toAssetData.asset.decimals.asInt),
            let fromPrice = getPrice(value: fromAmount, price: fromAssetData.price?.price),
            let toPrice = getPrice(value: toAmount, price: toAssetData.price?.price)
        else {
            return .none
        }
        let priceImpact = calculatePriceImpact(fromPrice: fromPrice, expectedPrice: toPrice)
        let priceImpactValue = evaluatePriceImpactValue(priceImpact: priceImpact)
        return priceImpactValue
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
    
    private func getPrice(value: Double, price: Double?) -> Double? {
        guard let price else {
            return nil
        }
        return value * price
    }
    
    private func evaluatePriceImpactValue(priceImpact: Double?) -> PriceImpactValue {
        guard
            let priceImpact,
            let priceImpactPercentage = percentFormatter.string(from: NSNumber(value: abs(priceImpact / 100)))
        else {
            return .none
        }
        
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
    
    private func calculatePriceImpact(fromPrice: Double, expectedPrice: Double) -> Double? {
        guard fromPrice > 0 else { return nil }
        let priceImpact = (1 - (expectedPrice / fromPrice)) * 100
        return priceImpact
    }
}
