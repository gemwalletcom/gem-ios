// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension CurrencyFormatter {
    enum Divisor: Double, Sendable {
        case value = 1
        case thousands = 1_000
        case millions = 1_000_000
        case billions = 1_000_000_000
        case trillions = 1_000_000_000_000
        
        var abbreviation: String {
            switch self {
            case .value: ""
            case .thousands: "K"
            case .millions: "M"
            case .billions: "B"
            case .trillions: "T"
            }
        }
        
        static var defaultDivisors: [Divisor] {
            [.value, .thousands, .millions, .billions, .trillions]
        }
    }
}
