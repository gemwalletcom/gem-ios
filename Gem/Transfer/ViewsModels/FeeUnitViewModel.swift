// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct FeeUnitViewModel {
    let unit: FeeUnit

    var value: String? {
        guard let unitValue else { return nil }
        switch unit.type {
        case .satVb:
            return Localized.FeeRate.satvB(unitValue)
        case .satB:
            return Localized.FeeRate.satB(unitValue)
        }
    }

    private var unitValue: Int? {
        let value = Double(unit.value.int)
        switch unit.type {
        case .satVb:
            return Int(round(value / 1000))
        case .satB:
            return Int(round(value / 100))
        }
    }
}
