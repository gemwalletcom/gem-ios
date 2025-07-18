// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetId {
    static func mock(
        _ assetId: AssetId = AssetId(chain: .bitcoin, tokenId: .none)
    ) -> AssetId {
        assetId
    }
    
    static func mock(_ chain: Chain) -> AssetId {
        AssetId(chain: chain, tokenId: .none)
    }
    
    static func mockEthereum() -> AssetId {
        AssetId(chain: .ethereum, tokenId: .none)
    }
    
    static func mockSolana() -> AssetId {
        AssetId(chain: .solana, tokenId: .none)
    }
    
    static func mockSolanaUSDC() -> AssetId {
        AssetId(chain: .solana, tokenId: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
    }
}
