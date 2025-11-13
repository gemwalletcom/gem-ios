// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct PerpetualPriceFormatter {
    
    public init() {}
    
    // https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api/tick-and-lot-size
    public func formatPrice(provider: PerpetualProvider, _ price: Double, decimals: Int) -> String {
        // Prices: up to 5 significant figures, max decimal places = 6 - szDecimals
        let formatter = NumberFormatter()
        formatter.locale = .US
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 5
        formatter.usesGroupingSeparator = false
        
        guard let result = formatter.string(from: NSNumber(value: price)) else {
            return String(price)
        }
        
        // Apply max decimal constraint
        let maxDecimals = 6 - decimals
        if let dotIndex = result.firstIndex(of: ".") {
            let decimalCount = result.distance(from: result.index(after: dotIndex), to: result.endIndex)
            if decimalCount > maxDecimals {
                return String(format: "%.*f", maxDecimals, price)
            }
        }
        
        return result
    }
    
    public func formatSize(provider: PerpetualProvider, _ size: Double, decimals: Int) -> String {
        // Sizes: rounded to szDecimals
        let formatter = NumberFormatter()
        formatter.locale = .US
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimals
        formatter.roundingMode = .halfUp
        formatter.usesGroupingSeparator = false

        return formatter.string(from: NSNumber(value: size)) ?? String(format: "%.*f", decimals, size)
    }

    public func formatInputPrice(_ price: Double, locale: Locale = Locale.current, szDecimals: Int) -> String {
        let maxDecimals = 6 - szDecimals

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 5
        formatter.usesGroupingSeparator = false

        guard let result = formatter.string(from: NSNumber(value: price)) else {
            return String(price)
        }

        let decimalSeparator = formatter.decimalSeparator ?? "."
        if let dotIndex = result.firstIndex(of: Character(decimalSeparator)) {
            let decimalCount = result.distance(from: result.index(after: dotIndex), to: result.endIndex)
            if decimalCount > maxDecimals {
                formatter.usesSignificantDigits = false
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = maxDecimals
                return formatter.string(from: NSNumber(value: price)) ?? String(price)
            }
        }

        return result
    }
}
