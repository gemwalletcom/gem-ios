// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Primitives
import PrimitivesTestKit

struct WalletConnectionSessionAppMetadataTests {
    
    @Test
    func shortName() {
        #expect(WalletConnectionSessionAppMetadata.mock(name: "Polymarket - Buy & Sell Predictions").shortName == "Polymarket")
        #expect(WalletConnectionSessionAppMetadata.mock(name: "Uniswap: Trade Crypto").shortName == "Uniswap")
        #expect(WalletConnectionSessionAppMetadata.mock(name: "OpenSea - NFT Marketplace").shortName == "OpenSea")
        #expect(WalletConnectionSessionAppMetadata.mock(name: "Aave: DeFi Lending").shortName == "Aave")
        #expect(WalletConnectionSessionAppMetadata.mock(name: "  Compound  ").shortName == "Compound")
        #expect(WalletConnectionSessionAppMetadata.mock(name: "Sushiswap").shortName == "Sushiswap")
        #expect(WalletConnectionSessionAppMetadata.mock(name: "Multi-chain Wallet").shortName == "Multi")
        #expect(WalletConnectionSessionAppMetadata.mock(name: "App:Feature:SubFeature").shortName == "App")
        
        let longName = String(repeating: "A", count: 100)
        let expectedLongName = String(repeating: "A", count: 80)
        #expect(WalletConnectionSessionAppMetadata.mock(name: longName).shortName == expectedLongName)
        
        #expect(WalletConnectionSessionAppMetadata.mock(name: "  " + longName + "  ").shortName == expectedLongName)
    }
}