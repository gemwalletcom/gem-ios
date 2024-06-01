// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct ValueFormatter {
    
    public enum Style {
        case short
        case medium
        case full
    }
    
    private let locale: Locale
    private let style: Self.Style
    
    public init(
        locale: Locale = .current,
        style: Self.Style
    ) {
        self.locale = locale
        self.style = style
    }
    
    private var formatterShort: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingIncrement = 0
        formatter.roundingMode = .down
        return formatter
    }
    
    private var formatterMedium: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        formatter.roundingIncrement = 0
        formatter.roundingMode = .down
        return formatter
    }
    
    private var formatterFull: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 32
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 32
        formatter.usesSignificantDigits = true
        formatter.roundingIncrement = 0
        formatter.roundingMode = .down
        return formatter
    }
    
    private var formatterSmallValues: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.maximumSignificantDigits = 2
        formatter.roundingIncrement = 0
        formatter.roundingMode = .down
        return formatter
    }
    
    public func inputNumber(from string: String, decimals: Int) throws -> BigInt {
        var string = string
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
        
        if let groupingSeparator = locale.groupingSeparator, groupingSeparator == "’" {
            string = string.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        if let groupingSeparator = locale.groupingSeparator, let decimalSeparator = locale.decimalSeparator, decimalSeparator == "." {
            string = string.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        if let groupingSeparator = locale.groupingSeparator, (groupingSeparator != "," && groupingSeparator != ".") {
            string = string.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        if let groupingSeparator = locale.groupingSeparator, groupingSeparator == "," && string.contains(".")  {
            string = string.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        if let groupingSeparator = locale.groupingSeparator, (groupingSeparator == ",") && !string.contains(".") {
            let newString = string.replacingOccurrences(of: ",", with: ".")
            if try number(amount: newString).doubleValue <= 1 {
                string = newString
            }
        }
        
        if let groupingSeparator = locale.groupingSeparator, (groupingSeparator != "," && !groupingSeparator.contains("'") && !groupingSeparator.contains("’"))  && !string.contains(",") {
            let newString = string.replacingOccurrences(of: ".", with: ",")
            if try number(amount: newString).doubleValue <= 1 {
                string = newString
            }
        }

        let value = try number(amount: string, locale: locale)
        
//        if let groupingSeparator = locale.groupingSeparator, groupingSeparator == "," && !string.contains(".") {
//            let newString = string.replacingOccurrences(of: ",", with: ".")
//            if try number(amount: newString).doubleValue <= 1 {
//                return try BigNumberFormatter.standard.number(from: newString, decimals: decimals)
//            }
//        }
//        if let groupingSeparator = locale.groupingSeparator, groupingSeparator != "," && !string.contains(",") {
//            let newString = string.replacingOccurrences(of: ".", with: ",")
//            if try number(amount: newString).doubleValue <= 1 {
//                return try BigNumberFormatter().number(from: newString, decimals: decimals)
//            } else {
//                return try BigNumberFormatter().number(from: string, decimals: decimals)
//            }
//        }
        return try BigNumberFormatter.standard.number(from: value.description, decimals: decimals)
    }
    
    public func string(_ value: BigInt, decimals: Int, currency: String = "") -> String {
        guard let decimal = BigNumberFormatter.standard.decimal(from: value, decimals: decimals) else {
            return ""
        }
        let number = NSDecimalNumber(decimal: decimal)
        
        let formatter = {
            let formatter = self.formatter(style: style)
            if value == 0 {
                formatter.maximumFractionDigits = 0
                return formatter
            }
            if abs(decimal) < 0.1 && value != 0 {
                formatter.maximumFractionDigits = formatter.maximumFractionDigits * 2
                return formatter
            }
            return formatter
        }()
        formatter.currencySymbol = currency
        formatter.currencyCode = currency
        formatter.internationalCurrencySymbol = currency
        
        guard let value = formatter.string(from: number) else {
            return ""
        }
        if currency.isEmpty {
            return value
        }
        return String(format: "%@ %@", value, currency)
    }
    
    public func number(amount: String) throws -> Decimal {
        return try number(amount: amount, locale: locale)
    }
    
    public func number(amount: String, locale: Locale) throws -> Decimal {
        guard let decimal = Decimal(string: amount, locale: locale) else {
            throw AnyError("unknown \(amount) decimal")
        }
        return decimal
    }
    
    public func double(from number: BigInt, decimals: Int) throws -> Double {
        guard let number = BigNumberFormatter.standard.double(from: number, decimals: decimals) else {
            throw AnyError("unknown \(number) number")
        }
        return number
    }
    
    private func formatter(style: ValueFormatter.Style) -> Foundation.NumberFormatter {
        switch style {
        case .short: formatterShort
        case .medium: formatterMedium
        case .full: formatterFull
        }
    }
}
