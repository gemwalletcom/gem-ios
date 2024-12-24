// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style

struct ChainViewModel {
    private let chain: Chain

    init(chain: Chain) {
        self.chain = chain
    }

    var title: String { asset.name }

    var image: Image {
        switch chain {
        case .bitcoin: Images.Chains.bitcoin
        case .bitcoinCash: Images.Chains.bitcoincash
        case .litecoin: Images.Chains.litecoin
        case .ethereum: Images.Chains.ethereum
        case .smartChain: Images.Chains.smartchain
        case .solana: Images.Chains.solana
        case .polygon: Images.Chains.polygon
        case .thorchain: Images.Chains.thorchain
        case .cosmos: Images.Chains.cosmos
        case .osmosis: Images.Chains.osmosis
        case .arbitrum: Images.Chains.arbitrum
        case .ton: Images.Chains.ton
        case .tron: Images.Chains.tron
        case .doge: Images.Chains.doge
        case .optimism: Images.Chains.optimism
        case .aptos: Images.Chains.aptos
        case .base: Images.Chains.base
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
        case .blast: Images.Chains.blast
        case .noble: Images.Chains.noble
        case .zkSync: Images.Chains.zksync
        case .linea: Images.Chains.linea
        case .mantle: Images.Chains.mantle
        case .celo: Images.Chains.celo
        case .near: Images.Chains.near
        case .world: Images.Chains.world
        case .stellar: Images.Chains.stellar
        case .sonic: Images.Chains.sonic
        case .algorand: Images.Chains.algorand
        case .polkadot: Images.Chains.polkadot
        case .cardano: Images.Chains.cardano
        }
    }

    private var asset: Asset { Asset(chain) }
}
