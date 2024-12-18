// Copyright (c). Gem Wallet. All rights reserved.

import WalletCorePrimitives
import Primitives
import WalletCore
import Testing

final class Chain_WalletCorePrimitiveTests {
    @Test(arguments: Chain.allCases)
       func testChainToCoinType(chain: Chain) {
           let coinType = chain.coinType
           switch chain {
           case .bitcoin:
               #expect(coinType == .bitcoin)
           case .litecoin:
               #expect(coinType == .litecoin)
           case .ethereum,
                .smartChain,
                .polygon,
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
               #expect(coinType == .ethereum)
           case .solana:
               #expect(coinType == .solana)
           case .thorchain:
               #expect(coinType == .thorchain)
           case .cosmos:
               #expect(coinType == .cosmos)
           case .osmosis:
               #expect(coinType == .osmosis)
           case .ton:
               #expect(coinType == .ton)
           case .tron:
               #expect(coinType == .tron)
           case .doge:
               #expect(coinType == .dogecoin)
           case .aptos:
               #expect(coinType == .aptos)
           case .sui:
               #expect(coinType == .sui)
           case .xrp:
               #expect(coinType == .xrp)
           case .celestia:
               #expect(coinType == .tia)
           case .injective:
               #expect(coinType == .nativeInjective)
           case .sei:
               #expect(coinType == .sei)
           case .noble:
               #expect(coinType == .noble)
           case .near:
               #expect(coinType == .near)
           case .stellar:
               #expect(coinType == .stellar)
           }
       }

    @Test
       func testCoinTypeToChain() {
           // Using #expect to verify expectations:
           #expect(WalletCore.CoinType.ethereum.chain == .ethereum)
           #expect(WalletCore.CoinType.bitcoin.chain == .bitcoin)

           // If smartChain and arbitrum do not map back to a chain, we expect nil
           #expect(WalletCore.CoinType.smartChain.chain == nil)
           #expect(WalletCore.CoinType.arbitrum.chain == nil)
       }
}
