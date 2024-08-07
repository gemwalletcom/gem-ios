// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct FeeUnitViewModel {
    let feetUnit: FeeUnit

    var value: String? {
        guard let unitValue else { return nil }
        switch feetUnit.type {
        case .satVb:
            return Localized.FeeRate.satvB(unitValue)
        case .satB:
            return Localized.FeeRate.satB(unitValue)
        }
    }

    private var unitValue: Int? {
        let value = Double(feetUnit.value.int)
        switch feetUnit.type {
        case .satVb:
            return Int(round(value / 1000))
        case .satB:
            return Int(round(value / 100))
        }
    }
}
