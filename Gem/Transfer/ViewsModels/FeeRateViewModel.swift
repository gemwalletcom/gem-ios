// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation
import Style

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
        case .slow: String(format: "%@  %@", Emoji.turle, Localized.FeeRates.slow)
        case .normal: String(format: "%@  %@", Emoji.gem, Localized.FeeRates.normal)
        case .fast: String(format: "%@  %@", Emoji.rocket, Localized.FeeRates.fast)
        }
    }

    var feeUnitModel: FeeUnitViewModel? {
        guard let type = chain.feeUnitType else { return nil }
        let unit = FeeUnit(type: type, value: feeRate.value)
        return FeeUnitViewModel(unit: unit)
    }

    var value: String? {
        feeUnitModel?.value
    }
}
