// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation
import Style
import Localization
import SwiftUI
import Components
import Formatters

public struct FeeRateViewModel: Identifiable {
    static let formatter = CurrencyFormatter(currencyCode: .empty)

    public let feeRate: FeeRate
    public let unitType: FeeUnitType
    public let decimals: Int
    public let symbol: String

    public init(
        feeRate: FeeRate,
        unitType: FeeUnitType,
        decimals: Int,
        symbol: String
    ) {
        self.feeRate = feeRate
        self.unitType = unitType
        self.decimals = decimals
        self.symbol = symbol
    }

    public var id: String { feeRate.priority.rawValue }

    public var emoji: String {
        switch feeRate.priority {
        case .fast: Emoji.FeeRate.fast.rawValue
        case .normal: Emoji.FeeRate.normal.rawValue
        case .slow: Emoji.FeeRate.slow.rawValue
        }
    }
    
    public var title: String {
        switch feeRate.priority {
        case .slow: Localized.FeeRates.slow
        case .normal: Localized.FeeRates.normal
        case .fast: Localized.FeeRates.fast
        }
    }

    public var feeUnitModel: FeeUnitViewModel {
        let unit = FeeUnit(type: unitType, value: feeRate.gasPriceType.totalFee)
        return FeeUnitViewModel(
            unit: unit,
            decimals: decimals,
            symbol: symbol,
            formatter: Self.formatter
        )
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
