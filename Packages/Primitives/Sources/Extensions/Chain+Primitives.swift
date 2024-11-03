// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Chain {
    public var assetId: AssetId {
        return AssetId(chain: self, tokenId: .none)
    }
    
    public var type: ChainType {
        switch self {
        case .bitcoin,
            .doge,
            .litecoin:
            return .bitcoin
        case .ethereum,
            .smartChain,
            .arbitrum,
            .optimism,
            .base,
            .avalancheC,
            .opBNB,
            .fantom,
            .gnosis,
            .manta,
            .blast,
            .zkSync,
            .linea,
            .mantle,
            .celo,
            .world:
            return .ethereum
        case .solana:
            return .solana
        case .polygon:
            return .ethereum
        case .cosmos,
            .thorchain,
            .osmosis,
            .celestia,
            .injective,
            .sei,
            .noble:
            return .cosmos
        case .ton:
            return .ton
        case .tron:
            return .tron
        case .aptos:
            return .aptos
        case .sui:
            return .sui
        case .xrp:
            return .xrp
        case .near:
            return .near
        }
    }
}

extension Chain: Identifiable {
    public var id: String { rawValue }
}

extension Chain {
    public var stakeChain: StakeChain? {
        StakeChain(rawValue: rawValue)
    }

    public var feeUnitType: FeeUnitType? {
        switch self.type {
        case .bitcoin:
            BitcoinChain(rawValue: rawValue)?.feeUnitType
        case .ethereum, .aptos, .solana, .cosmos, .ton, .tron, .sui, .xrp, .near:
            nil
        }
    }
}
