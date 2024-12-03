// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation
import Style
import Localization
import SwiftUI

public struct FeeRateViewModel: Identifiable {
    static let formatter = CurrencyFormatter()

    public let feeRate: FeeRate
    public let chain: Chain

    public init(feeRate: FeeRate, chain: Chain) {
        self.feeRate = feeRate
        self.chain = chain
    }

    public var id: String { feeRate.priority.rawValue }

    public var image: Image? {
        //TODO Specify image for each priority type
        .none
    }
    
    public var title: String {
        switch feeRate.priority {
        case .slow: Localized.FeeRates.slow
        case .normal: Localized.FeeRates.normal
        case .fast: Localized.FeeRates.fast
        }
    }

    public var feeUnitModel: FeeUnitViewModel? {
        guard let type = chain.feeUnitType else { return nil }
        let unit = FeeUnit(type: type, value: feeRate.gasPrice)
        return FeeUnitViewModel(unit: unit, formatter: Self.formatter)
    }

    public var value: String? {
        feeUnitModel?.value
    }
}
