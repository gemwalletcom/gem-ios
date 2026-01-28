// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct IntegerFormatter: Sendable {
    
    private let locale: Locale
    private var integerFormatter: Foundation.NumberFormatter {
        let formatter = Foundation.NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter
    }
    
    static let standard = IntegerFormatter()
    
    public init(
        locale: Locale = Locale.current
    ) {
        self.locale = locale
    }
    
    public func string(_ number: Int) -> String {
        integerFormatter.string(from: NSNumber(value: number))!
    }
    
    public func string(_ number: Double, symbol: String? = .none) -> String {
        let result = integerFormatter.string(from: NSNumber(value: Int(number)))!
        if let symbol {
            return "\(result) \(symbol)"
        }
        return result
    }
}
