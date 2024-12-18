// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Chain {
    public init(id: String) throws {
        if let chain = Chain(rawValue: id) {
            self = chain
        } else {
            throw AnyError("invalid chain id: \(id)")
        }
    }
    
    public var assetId: AssetId {
        return AssetId(chain: self, tokenId: .none)
    }
    
    //TODO: Gemstone
    public var type: ChainType {
        switch self {
        case .bitcoin,
            .doge,
            .litecoin: .bitcoin
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
            .world,
            .sonic: .ethereum
        case .solana: .solana
        case .polygon: .ethereum
        case .cosmos,
            .thorchain,
            .osmosis,
            .celestia,
            .injective,
            .sei,
            .noble: .cosmos
        case .ton: .ton
        case .tron: .tron
        case .aptos: .aptos
        case .sui: .sui
        case .xrp: .xrp
        case .near: .near
        case .stellar: .stellar
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

    public var feeUnitType: FeeUnitType {
        switch self.type {
        case .bitcoin: .satVb
        case .ethereum: .gwei
        case .aptos,
            .solana,
            .cosmos,
            .ton,
            .tron,
            .sui,
            .xrp,
            .near,
            .stellar: .native
        }
    }
}
