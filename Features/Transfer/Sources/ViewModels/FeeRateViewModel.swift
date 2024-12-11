// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation
import Style
import Localization
import SwiftUI

public struct FeeRateViewModel: Identifiable {
    static let formatter = CurrencyFormatter()

    public let feeRate: FeeRate
    public let unitType: FeeUnitType

    public init(
        feeRate: FeeRate,
        unitType: FeeUnitType
    ) {
        self.feeRate = feeRate
        self.unitType = unitType
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

    public var feeUnitModel: FeeUnitViewModel {
        let unit = FeeUnit(type: unitType, value: feeRate.gasPriceType.total)
        return FeeUnitViewModel(unit: unit, formatter: Self.formatter)
    }

    public var valueText: String {
        feeUnitModel.value
    }
}

extension FeeRateViewModel: Comparable {
    public static func < (lhs: FeeRateViewModel, rhs: FeeRateViewModel) -> Bool {
        lhs.feeRate.priority.rank > rhs.feeRate.priority.rank
    }
}
