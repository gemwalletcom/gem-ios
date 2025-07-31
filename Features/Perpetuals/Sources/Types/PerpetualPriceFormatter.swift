// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct PerpetualPriceFormatter {
    
    init() {}
    
    // https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api/tick-and-lot-size
    func formatPrice(_ price: Double, decimals: Int) -> String {
        // For perpetuals: max decimal places = 6 - szDecimals
        let maxDecimalPlaces = 6 - decimals
        
        // Apply 5 significant figures with max decimal constraint
        return formatWithSignificantFigures(price, sigFigs: 5, maxDecimals: maxDecimalPlaces)
    }
    
    private func formatWithSignificantFigures(_ value: Double, sigFigs: Int, maxDecimals: Int) -> String {
        // First apply significant figures
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = sigFigs
        formatter.usesGroupingSeparator = false
        formatter.roundingMode = .halfUp
        
        guard let sigFigResult = formatter.string(from: NSNumber(value: value)) else {
            return String(format: "%g", value)
        }
        
        // Then check if we need to limit decimal places
        if sigFigResult.contains(".") {
            let components = sigFigResult.split(separator: ".")
            if components.count == 2 && components[1].count > maxDecimals {
                // Round to max decimal places
                return String(format: "%.*f", maxDecimals, value)
            }
        }
        
        return sigFigResult
    }
    
    func formatSize(_ size: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 16
        f.usesGroupingSeparator = false
        return f.string(from: NSNumber(value: size))!
    }
}
