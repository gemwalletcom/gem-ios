// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import GemstonePrimitives

struct AssetPropertiesTests {

    @Test func defaultValueIsStakeable() async throws {
        #expect(AssetProperties.defaultValue(assetId: AssetId(chain: .smartChain)).isSwapable == true)
        #expect(AssetProperties.defaultValue(assetId: AssetId(chain: .smartChain, tokenId: "0x")).isStakeable == false)
        #expect(AssetProperties.defaultValue(assetId: .mockSolana()).isStakeable == true)
        #expect(AssetProperties.defaultValue(assetId: .mockSolanaUSDC()).isStakeable == false)
    }
    
    @Test func defaultValueIsSwapable() async throws {
        #expect(AssetProperties.defaultValue(assetId: AssetId(chain: .smartChain)).isSwapable == true)
        #expect(AssetProperties.defaultValue(assetId: AssetId(chain: .smartChain, tokenId: "0x")).isSwapable == true)
        #expect(AssetProperties.defaultValue(assetId: .mockSolana()).isSwapable == true)
        #expect(AssetProperties.defaultValue(assetId: .mockSolanaUSDC()).isSwapable == true)
    }
}
