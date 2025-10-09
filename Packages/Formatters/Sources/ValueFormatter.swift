// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct ValueFormatter: Sendable {
    public enum Style: Sendable {
        case short
        case medium
        case full
        case auto
        case abbreviated
    }
    
    private let locale: Locale
    private let style: Style
    private let abbreviationThreshold: Decimal
    
    public init(
        locale: Locale = .current,
        style: Style,
        abbreviationThreshold: Decimal = 100_000
    ) {
        self.locale = locale
        self.style = style
        self.abbreviationThreshold = abbreviationThreshold
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
    
    private var formatterMiddle: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumSignificantDigits = 4
        formatter.usesSignificantDigits = true
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
        formatter.maximumSignificantDigits = 32
        formatter.usesSignificantDigits = true
        formatter.roundingIncrement = 0
        formatter.roundingMode = .down
        return formatter
    }
    
    private var abbreviatedFormatter: AbbreviatedFormatter {
        AbbreviatedFormatter(locale: locale, threshold: abbreviationThreshold)
    }
    
    public func inputNumber(from string: String, decimals: Int) throws -> BigInt {
        // use standart formatter, which are en_US for getting correct BigInt value
        try BigNumberFormatter.standard.number(
            from: NumberInputNormalizer.normalize(string, locale: locale),
            decimals: decimals
        )
    }
    
    public func string(_ value: BigInt, asset: Asset) -> String {
        string(value, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    public func string(_ value: BigInt, decimals: Int, currency: String = "") -> String {
        guard let decimal = BigNumberFormatter.standard.decimal(from: value, decimals: decimals) else {
            return ""
        }
        let number = NSDecimalNumber(decimal: decimal)

        if let abbreviated = abbreviatedString(from: decimal, currency: currency) {
            return abbreviated
        }
        
        let formatter = {
            let formatter = self.formatter(style: style, number: number)
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
        return combined(value, currency: currency)
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
    
    private func formatter(style: ValueFormatter.Style, number: NSDecimalNumber) -> Foundation.NumberFormatter {
        switch style {
        case .short: formatterShort
        case .medium: formatterMedium
        case .full: formatterFull
        case .auto: autoFormatter(for: number)
        case .abbreviated: formatterShort
        }
    }
    
    private func autoFormatter(for number: NSDecimalNumber) -> NumberFormatter {
        switch number.doubleValue.magnitude {
        case 0: formatterShort
        case 1...: formatterShort
        case 0.0001..<1: formatterMiddle
        default: formatterFull
        }
    }

    private func abbreviatedString(from decimal: Decimal, currency: String) -> String? {
        guard case .abbreviated = style else {
            return nil
        }

        if let result = abbreviatedFormatter.string(from: decimal) {
            return combined(result, currency: currency)
        }
        return nil
    }

    private func combined(_ value: String, currency: String) -> String {
        if currency.isEmpty {
            return value
        }
        return String(format: "%@ %@", value, currency)
    }
}
