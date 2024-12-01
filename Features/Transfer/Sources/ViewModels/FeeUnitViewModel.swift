// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct FeeUnitViewModel {
    private static let formatter = CurrencyFormatter()

    private let unit: FeeUnit

    public init(unit: FeeUnit) {
        self.unit = unit
    }

    public var value: String {
        switch unit.type {
        case .satVb: Localized.FeeRate.satvB(unitValueString)
        case .gwei: Localized.FeeRate.gwei(unitValueString)
        }
    }

    private var conversionFactor: Double {
        switch unit.type {
        case .satVb: 1 / 1000
        case .gwei: 1 / 1_000_000_000
        }
    }

    private var unitValue: Double {
        Double(unit.value) * conversionFactor
    }

    private var unitValueString: String {
        Self.formatter.string(decimal: Decimal(unitValue))
            .replacingOccurrences(of: " ", with: "")
    }
}
