// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import WalletCorePrimitives
import Primitives
import WalletCore

final class Chain_WalletCorePrimitiveTests: XCTestCase {

    func testChainToCoinType() {
        for chain in Chain.allCases {
            let coinType = chain.coinType
            switch chain {
            case .bitcoin: XCTAssertEqual(coinType, .bitcoin)
            case .litecoin: XCTAssertEqual(coinType, .litecoin)
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
                .world: XCTAssertEqual(coinType, .ethereum)
            case .solana: XCTAssertEqual(coinType, .solana)
            case .thorchain: XCTAssertEqual(coinType, .thorchain)
            case .cosmos: XCTAssertEqual(coinType, .cosmos)
            case .osmosis: XCTAssertEqual(coinType, .osmosis)
            case .ton: XCTAssertEqual(coinType, .ton)
            case .tron: XCTAssertEqual(coinType, .tron)
            case .doge: XCTAssertEqual(coinType, .dogecoin)
            case .aptos: XCTAssertEqual(coinType, .aptos)
            case .sui: XCTAssertEqual(coinType, .sui)
            case .xrp: XCTAssertEqual(coinType, .xrp)
            case .celestia: XCTAssertEqual(coinType, .tia)
            case .injective: XCTAssertEqual(coinType, .nativeInjective)
            case .sei: XCTAssertEqual(coinType, .sei)
            case .noble: XCTAssertEqual(coinType, .noble)
            case .near: XCTAssertEqual(coinType, .near)
            }
        }
    }
    
    func testCoinTypeToChain() {
        XCTAssertEqual(WalletCore.CoinType.ethereum.chain, .ethereum)
        XCTAssertEqual(WalletCore.CoinType.bitcoin.chain, .bitcoin)
        
        XCTAssertNil(WalletCore.CoinType.smartChain.chain)
        XCTAssertNil(WalletCore.CoinType.arbitrum.chain)
    }
}
