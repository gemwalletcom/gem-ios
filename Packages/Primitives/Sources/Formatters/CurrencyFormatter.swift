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
    public var abbreviationThreshold: Decimal = 100_000
    
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
    
    public func string(decimal: Decimal, symbol: String? = nil) -> String {
        switch type {
        case .abbreviated: abbreviatedStringSymbol(decimal, symbol: symbol)
        case .currency, .percent, .percentSignLess: stringSymbol(decimal, symbol: symbol)
        }
    }
    
    public func normalizedDouble(from value: Double) -> Double? {
        let formatter = formatter(for: value)
        guard let formattedString = formatter.string(from: NSNumber(value: value)) else {
            return nil
        }
        return formatter.number(from: formattedString)?.doubleValue
    }
    
    // MARK: - Private methods
    
    private func abbreviatedString(_ number: Double) -> String {
        guard abs(number) >= abbreviationThreshold.doubleValue, #available(iOS 18, *) else {
            return currencyString(number)
        }
        return number
            .formatted(
                .currency(code: currencyCode)
                .notation(.compactName)
                .locale(locale)
                .precision(.fractionLength(0...2))
            )
    }
    
    private func abbreviatedStringSymbol(_ decimal: Decimal, symbol: String?) -> String {
        guard abs(decimal) >= abbreviationThreshold else {
            return stringSymbol(decimal, symbol: symbol)
        }
        let string = decimal
            .formatted(
                .number
                .notation(.compactName)
                .locale(locale)
                .precision(.fractionLength(0...2))
            )
        return combined(value: string, symbol: symbol)
    }
    
    private func stringSymbol(_ decimal: Decimal, symbol: String?) -> String {
        let formatter = formatter(for: decimal.doubleValue)
        formatter.currencySymbol = ""

        let value = formatter.string(from: NSDecimalNumber(decimal: decimal)) ?? ""
        return combined(value: value, symbol: symbol)
    }
    
    private func currencyString(_ number: Double) -> String {
        formatter(for: number).string(from: NSNumber(value: number))!
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
