// Copyright (c). Gem Wallet. All rights reserved.

import WalletCorePrimitives
import Primitives
import WalletCore
import Testing

final class Chain_WalletCorePrimitiveTests {
    @Test(arguments: Chain.allCases)
    func testChainToCoinType(chain: Chain) {
        let expected: CoinType
        switch chain {
        case .bitcoin:
            expected = .bitcoin
        case .litecoin:
            expected = .litecoin
        case .ethereum, .smartChain, .polygon, .arbitrum, .optimism, .base,
             .avalancheC, .opBNB, .fantom, .gnosis, .manta, .blast, .zkSync,
             .linea, .mantle, .celo, .world, .sonic, .abstract, .berachain,
             .ink, .unichain, .hyperliquid, .monad:
            expected = .ethereum
        case .solana:
            expected = .solana
        case .thorchain:
            expected = .thorchain
        case .cosmos:
            expected = .cosmos
        case .osmosis:
            expected = .osmosis
        case .ton:
            expected = .ton
        case .tron:
            expected = .tron
        case .doge:
            expected = .dogecoin
        case .aptos:
            expected = .aptos
        case .sui:
            expected = .sui
        case .xrp:
            expected = .xrp
        case .celestia:
            expected = .tia
        case .injective:
            expected = .nativeInjective
        case .sei:
            expected = .sei
        case .noble:
            expected = .noble
        case .near:
            expected = .near
        case .stellar:
            expected = .stellar
        case .bitcoinCash:
            expected = .bitcoinCash
        case .algorand:
            expected = .algorand
        case .polkadot:
            expected = .polkadot
        case .cardano:
            expected = .cardano
        }

        #expect(chain.coinType == expected)
    }
}
