// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

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

    var value: String {
        switch chain {
        case .bitcoin:
            let gasPrice = feeRate.value.int / 1000
            return "\(gasPrice) sat/vB"
        case .litecoin , .doge:
            let gasPrice = feeRate.value.int / 100
            return "\(gasPrice) sat/B"
        case .ethereum:
            return ""
        case .smartChain:
            return ""
        case .solana:
            return ""
        case .polygon:
            return ""
        case .thorchain:
            return ""
        case .cosmos:
            return ""
        case .osmosis:
            return ""
        case .arbitrum:
            return ""
        case .ton:
            return ""
        case .tron:
            return ""
        case .optimism:
            return ""
        case .aptos:
            return ""
        case .base:
            return ""
        case .avalancheC:
            return ""
        case .sui:
            return ""
        case .xrp:
            return ""
        case .opBNB:
            return ""
        case .fantom:
            return ""
        case .gnosis:
            return ""
        case .celestia:
            return ""
        case .injective:
            return ""
        case .sei:
            return ""
        case .manta:
            return ""
        case .blast:
            return ""
        case .noble:
            return ""
        case .zkSync:
            return ""
        case .linea:
            return ""
        case .mantle:
            return ""
        case .celo:
            return ""
        case .near:
            return ""
        }
    }
}
