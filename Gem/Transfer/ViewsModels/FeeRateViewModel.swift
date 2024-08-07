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
        guard let type = FeeUnitType.unit(chain: chain) else { return nil }
        let unitValue = FeeUnit(type: type, value: feeRate.value)
        return FeeUnitViewModel(feetUnit: unitValue)
    }

    var value: String? {
        feeUnitModel?.value
    }
}

// MARK: - Models extension

extension FeeUnitType {
    static func unit(chain: Chain) -> FeeUnitType? {
        switch chain.type {
        case .bitcoin:
            switch BitcoinChain(rawValue: chain.rawValue) {
            case .bitcoin: return .satVb
            case .litecoin, .doge: return .satB
            case .none: return .none
            }
        case .ethereum, .aptos, .solana, .cosmos, .ton, .tron, .sui, .xrp, .near:
            return nil
        }
    }
}
