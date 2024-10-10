import Foundation

public enum CurrencyFormatterType: Sendable {
    case currency
    case percent
    case percentSignLess
}

public struct CurrencyFormatter: Sendable {

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
    
    public func string(_ number: Double) -> String {
        switch type{
        case .currency:
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
    
    public func string(decimal: Decimal) -> String {
        let formatter = formatter(for: decimal.doubleValue)
        formatter.currencySymbol = ""
        return formatter.string(from: NSDecimalNumber(decimal: decimal)) ?? ""
    }
    
    private func formatter(for value: Double) -> NumberFormatter {
        if (abs(value) > 0.01 || value == 0) {
            formatter
        } else {
            formatterSmallValues
        }
    }
}

