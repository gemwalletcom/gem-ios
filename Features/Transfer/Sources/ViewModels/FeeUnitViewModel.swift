// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct FeeUnitViewModel {
    private let unit: FeeUnit
    private let formatter: CurrencyFormatter

    public init(unit: FeeUnit, formatter: CurrencyFormatter) {
        self.unit = unit
        self.formatter = formatter
    }

    public var value: String {
        switch unit.type {
        case .satVb: Localized.FeeRate.satvB(unitValueString)
        case .gwei: Localized.FeeRate.gwei(unitValueString)
        case .satB: Localized.FeeRate.satB(unitValueString)
        }
    }

    private var conversionFactor: Double {
        switch unit.type {
        case .satVb: 1 / 1_000
        case .gwei: 1 / 1_000_000_000
        case .satB: 4 / 1_000
        }
    }

    private var unitValue: Double {
        Double(unit.value) * conversionFactor
    }

    private var unitValueString: String {
        formatter.string(decimal: Decimal(unitValue))
            .replacingOccurrences(of: " ", with: "")
    }
}
