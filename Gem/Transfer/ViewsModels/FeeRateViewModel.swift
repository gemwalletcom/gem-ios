// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation

struct FeeRateViewModel: Identifiable {
    let feeRate: FeeRate
    let chain: Chain

    init(feeRate: FeeRate, chain: Chain) {
        self.feeRate = feeRate
        self.chain = chain
    }

    var id: String { feeRate.priority.rawValue }

    var title: String {
        switch feeRate.priority {
        case .fast: return Localized.FeeRates.fast
        case .normal: return Localized.FeeRates.normal
        case .slow: return Localized.FeeRates.slow
        }
    }

    var feeUnitModel: FeeUnitViewModel? {
        guard let type = chain.type.feeUnitType else { return nil }
        let unit = FeeUnit(type: type, value: feeRate.value)
        return FeeUnitViewModel(unit: unit)
    }

    var value: String? {
        feeUnitModel?.value
    }
}
