import Foundation

public enum CurrencyFormatterType: Sendable, Hashable {
    case currency
    case abbreviated
    case percent
    case percentSignLess
}

public struct CurrencyFormatter: Sendable, Hashable {

    private let locale: Locale
    private let type: CurrencyFormatterType
    
    private var formatter: Foundation.NumberFormatter {
        let formatter = Foundation.NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = currencyCode
        return formatter
    }
    
    private var formatterSmallValues: Foundation.NumberFormatter {
        let formatter = Foundation.NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 8
        formatter.maximumSignificantDigits = 2
        formatter.currencyCode = currencyCode
        return formatter
    }
    
    private var percentFormatter: Foundation.NumberFormatter {
        let formatter = Foundation.NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.positivePrefix = formatter.plusSign
        return formatter
    }
    
    private var percentSignLessFormatter: Foundation.NumberFormatter {
        let formatter = Foundation.NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.positivePrefix = .empty
        return formatter
    }
    
    public static let percent = CurrencyFormatter(type: .percent)

    public var currencyCode: String
    public var abbreviationThreshold: Double = 100_000
    
    public init(
        type: CurrencyFormatterType = .currency,
        locale: Locale = Locale.current,
        currencyCode: String = Locale.current.currency?.identifier ?? .empty
    ) {
        self.type = type
        self.locale = locale
        self.currencyCode = currencyCode
    }
    
    public var symbol: String {
        switch type {
        case .currency, .abbreviated: formatter.currencySymbol
        case .percent, .percentSignLess: percentFormatter.percentSymbol
        }
    }
    
    public func string(_ number: Double) -> String {
        switch type {
        case .currency: currencyString(number)
        case .percent: percentFormatter.string(from: NSNumber(value: number/100))!
        case .percentSignLess: percentSignLessFormatter.string(from: NSNumber(value: number/100))!
        case .abbreviated: abbreviatedString(number)
        }
    }
    
    public func string(double: Double, symbol: String? = nil) -> String {
        switch type {
        case .abbreviated: abbreviatedStringSymbol(double, symbol: symbol)
        case .currency, .percent, .percentSignLess: stringSymbol(double, symbol: symbol)
        }
    }
    
    public func double(from amount: String) -> Double? {
        guard let decimal = Decimal(string: amount, locale: locale) else {
            return nil
        }
        return normalizedDouble(from: decimal.doubleValue)
    }
    
    public func normalizedDouble(from value: Double) -> Double? {
        let formatter = formatter(for: value)
        formatter.currencySymbol = ""
        guard let formattedString = formatter.string(from: NSNumber(value: value)) else {
            return nil
        }
        return formatter.number(from: formattedString)?.doubleValue
    }
    
    // MARK: - Private methods
    
    private func abbreviatedString(_ double: Double) -> String {
        guard abs(double) >= abbreviationThreshold, #available(iOS 18, *) else {
            return currencyString(double)
        }
        return double
            .formatted(
                .currency(code: currencyCode)
                .notation(.compactName)
                .locale(locale)
                .precision(.fractionLength(0...2))
            )
    }
    
    private func abbreviatedStringSymbol(_ double: Double, symbol: String?) -> String {
        guard abs(double) >= abbreviationThreshold else {
            return stringSymbol(double, symbol: symbol)
        }
        let string = double
            .formatted(
                .number
                .notation(.compactName)
                .locale(locale)
                .precision(.fractionLength(0...2))
            )
        return combined(value: string, symbol: symbol)
    }
    
    private func stringSymbol(_ double: Double, symbol: String?) -> String {
        let formatter = formatter(for: double)
        formatter.currencySymbol = ""

        let value = formatter.string(from: NSNumber(value: double)) ?? ""
        return combined(value: value, symbol: symbol)
    }
    
    private func currencyString(_ double: Double) -> String {
        formatter(for: double).string(from: NSNumber(value: double))!
    }
    
    private func formatter(for value: Double) -> NumberFormatter {
        if (abs(value) >= 0.1 || value == 0 || value < 0.000_000_000_1) {
            formatter
        } else {
            formatterSmallValues
        }
    }
    
    private func combined(value: String, symbol: String?) -> String {
        [value, symbol].compactMap { $0 }.joined(separator: " ")
    }
}
