import Foundation

public enum CurrencyFormatterType: Sendable, Hashable {
    case currency
    case currencyShort
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
    
    private var shortFormatter: Foundation.NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter
    }
    
    public static let percent = CurrencyFormatter(type: .percent)

    public var includePlusSign: Bool = false
    public var currencyCode: String
    
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
        case .currency, .currencyShort: formatter.currencySymbol
        case .percent, .percentSignLess: percentFormatter.percentSymbol
        }
    }
    
    public func string(_ number: Double) -> String {
        switch type {
        case .currency, .currencyShort:
            let formatter = formatter(for: number)
            if includePlusSign && number == 0 {
                return "\(formatter.string(from: NSNumber(value: number))!)"
            } else if includePlusSign && number > 0 {
                return "+\(formatter.string(from: NSNumber(value: number))!)"
            }
            return formatter.string(from: NSNumber(value: number))!
        case .percent:
            return percentFormatter.string(from: NSNumber(value: number/100))!
        case .percentSignLess:
            return percentSignLessFormatter.string(from: NSNumber(value: number/100))!
        }
    }
    
    public func string(decimal: Decimal, symbol: String = .empty) -> String {
        let formatter = formatter(for: decimal.doubleValue)
        formatter.currencySymbol = ""

        let value = formatter.string(from: NSDecimalNumber(decimal: decimal)) ?? ""
        return [value, symbol].filter { !$0.isEmpty }.joined(separator: " ")
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
    
    private func formatter(for value: Double) -> NumberFormatter {
        switch type {
        case .currencyShort: shortFormatter
        case .currency, .percent, .percentSignLess:
            if (abs(value) >= 0.1 || value == 0 || value < 0.000_000_000_1) {
                formatter
            } else {
                formatterSmallValues
            }
        }
    }
}
