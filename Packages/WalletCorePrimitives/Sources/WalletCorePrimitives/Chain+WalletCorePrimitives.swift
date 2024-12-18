// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

public extension Chain {
    var coinType: WalletCore.CoinType {
        switch self {
        case .bitcoin: .bitcoin
        case .litecoin: .litecoin
        case .ethereum,
            .arbitrum,
            .polygon,
            .optimism,
            .base,
            .avalancheC,
            .opBNB,
            .fantom,
            .gnosis,
            .manta,
            .smartChain,
            .blast,
            .zkSync,
            .linea,
            .mantle,
            .celo,
            .world: .ethereum
        case .solana: .solana
        case .thorchain: .thorchain
        case .cosmos: .cosmos
        case .osmosis: .osmosis
        case .ton: .ton
        case .tron: .tron
        case .doge: .dogecoin
        case .aptos: .aptos
        case .sui: .sui
        case .xrp: .xrp
        case .celestia: .tia
        case .injective: .nativeInjective
        case .sei: .sei
        case .noble: .noble
        case .near: .near
        case .stellar: .stellar
        }
    }
}

public extension WalletCore.CoinType {
    var chain: Chain? {
        switch self {
        case .bitcoin: .bitcoin
        case .litecoin: .litecoin
        case .ethereum: .ethereum
        case .smartChain,
            .polygon,
            .arbitrum,
            .optimism,
            .base,
            .avalancheCChain,
            .opBNB,
            .fantom,
            .xdai,
            .mantaPacific: .none
        case .solana: .solana
        case .thorchain: .thorchain
        case .cosmos: .cosmos
        case .osmosis: .osmosis
        case .ton: .ton
        case .tron: .tron
        case .dogecoin: .doge
        case .aptos: .aptos
        case .sui: .sui
        case .xrp: .xrp
        case .tia: .celestia
        case .nativeInjective: .injective
        case .sei: .sei
        case .noble: .noble
        case .near: .near
        default:
            fatalError()
        }
    }
}
