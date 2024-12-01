// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation
import Style
import Localization
import SwiftUI
import Transfer

struct FeeRateViewModel: Identifiable {
    let feeRate: FeeRate
    let chain: Chain

    init(feeRate: FeeRate, chain: Chain) {
        self.feeRate = feeRate
        self.chain = chain
    }

    var id: String { feeRate.priority.rawValue }

    var image: Image? {
        //TODO Specify image for each priority type
        .none
    }
    
    var title: String {
        switch feeRate.priority {
        case .slow: Localized.FeeRates.slow
        case .normal: Localized.FeeRates.normal
        case .fast: Localized.FeeRates.fast
        }
    }

    var feeUnitModel: FeeUnitViewModel? {
        guard let type = chain.feeUnitType else { return nil }
        let unit = FeeUnit(type: type, value: feeRate.gasPrice)
        return FeeUnitViewModel(unit: unit)
    }

    var value: String? {
        feeUnitModel?.value
    }
}
