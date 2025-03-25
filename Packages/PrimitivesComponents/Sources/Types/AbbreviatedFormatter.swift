// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct AbbreviatedFormatter: Sendable {
    private let currencyFormatter: CurrencyFormatter
    private let divisors: [Divisor]
    
    public init(
        divisors: [Divisor] = [.value, .thousands, .millions, .billions, .trillions],
        locale: Locale = Locale.current,
        currencyCode: String = Locale.current.currency?.identifier ?? .empty
    ) {
        self.divisors = divisors
        currencyFormatter = CurrencyFormatter(type: .currencyShort, locale: locale, currencyCode: currencyCode)
    }
    
    // MARK: - Public methods
    
    public func string(_ number: Double) -> String {
        guard let divisor = divisor(for: number) else {
            return currencyFormatter.string(number)
        }
        let dividedValue = dividedValue(number, divisor: divisor)
        let formatted = currencyFormatter.string(dividedValue)
        return String(format: "%@%@", formatted, divisor.abbreviation)
    }
    
    public func stringSymbol(_ number: Double, symbol: String = .empty) -> String {
        guard let divisor = divisor(for: number) else {
            return currencyFormatter.string(decimal: Decimal(number), symbol: symbol)
        }
        let dividedValue = dividedValue(number, divisor: divisor)
        let value = currencyFormatter.string(decimal: Decimal(dividedValue))
        let abbreviated = String(format: "%@%@", value, divisor.abbreviation)
        return [abbreviated, symbol].filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    // MARK: - Private methods
    
    private func divisor(for number: Double) -> Divisor? {
        divisors.reversed().first(where: { abs(number) >= $0.rawValue })
    }
    
    private func dividedValue(_ number: Double, divisor: Divisor) -> Double {
        number / divisor.rawValue
    }
}

// MARK: - Divisor

extension AbbreviatedFormatter {
    public enum Divisor: Double, Sendable {
        case value = 1
        case thousands = 1_000
        case millions = 1_000_000
        case billions = 1_000_000_000
        case trillions = 1_000_000_000_000
        
        var abbreviation: String {
            switch self {
            case .value: .empty
            case .thousands: Localized.Abbreviation.Divisor.thousands
            case .millions: Localized.Abbreviation.Divisor.millions
            case .billions: Localized.Abbreviation.Divisor.billions
            case .trillions: Localized.Abbreviation.Divisor.trillions
            }
        }
    }
}
