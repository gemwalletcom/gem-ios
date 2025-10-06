// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style

public struct ChainImage: Sendable {
    private let chain: Chain

    public init(chain: Chain) {
        self.chain = chain
    }

    public var image: Image {
        switch chain {
        case .bitcoin: Images.Chains.bitcoin
        case .bitcoinCash: Images.Chains.bitcoincash
        case .litecoin: Images.Chains.litecoin
        case .ethereum,
            .base,
            .optimism,
            .zkSync,
            .abstract,
            .unichain,
            .ink,
            .linea,
            .arbitrum,
            .blast,
            .world: Images.Chains.ethereum
        case .smartChain: Images.Chains.smartchain
        case .celo: Images.Chains.celo
        case .solana: Images.Chains.solana
        case .polygon: Images.Chains.polygon
        case .thorchain: Images.Chains.thorchain
        case .cosmos: Images.Chains.cosmos
        case .osmosis: Images.Chains.osmosis
        case .ton: Images.Chains.ton
        case .tron: Images.Chains.tron
        case .doge: Images.Chains.doge
        case .aptos: Images.Chains.aptos
        case .avalancheC: Images.Chains.avalanchec
        case .sui: Images.Chains.sui
        case .xrp: Images.Chains.xrp
        case .opBNB: Images.Chains.opbnb
        case .fantom: Images.Chains.fantom
        case .gnosis: Images.Chains.gnosis
        case .celestia: Images.Chains.celestia
        case .injective: Images.Chains.injective
        case .sei: Images.Chains.sei
        case .manta: Images.Chains.manta
        case .noble: Images.Chains.noble
        case .mantle: Images.Chains.mantle
        case .near: Images.Chains.near
        case .stellar: Images.Chains.stellar
        case .sonic: Images.Chains.sonic
        case .algorand: Images.Chains.algorand
        case .polkadot: Images.Chains.polkadot
        case .cardano: Images.Chains.cardano
        case .berachain: Images.Chains.berachain
        case .hyperliquid, .hyperCore: Images.Chains.hyperliquid
        case .monad: Images.Chains.monad
        case .plasma: Images.Chains.plasma
        case .zcash: Images.Chains.zcash
        }
    }
    
    public var placeholder: Image {
        l2Image ?? image
    }
    
    public var l2Image: Image? {
        switch chain {
        case .optimism: Images.Chains.optimism
        case .base: Images.Chains.base
        case .zkSync: Images.Chains.zksync
        case .arbitrum: Images.Chains.arbitrum
        case .abstract: Images.Chains.abstract
        case .unichain: Images.Chains.unichain
        case .ink: Images.Chains.ink
        case .linea: Images.Chains.linea
        case .opBNB: Images.Chains.opbnb
        case .blast: Images.Chains.blast
        case .world: Images.Chains.world
        case .manta: Images.Chains.manta
        default: nil
        }
    }
}

// MARK: - Identifiable

extension ChainImage: Identifiable {
    public var id: String { chain.rawValue }
}
