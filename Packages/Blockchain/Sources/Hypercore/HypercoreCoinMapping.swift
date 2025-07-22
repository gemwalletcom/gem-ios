// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public func mapHypercoreCoinToAssetId(_ coin: String) -> AssetId? {
    switch coin.uppercased() {
    case "ETH": AssetId(chain: .ethereum, tokenId: nil)
    case "BTC": AssetId(chain: .bitcoin, tokenId: nil)
    case "SUI": AssetId(chain: .sui, tokenId: nil)
    case "HYPE": AssetId(chain: .hyperCore, tokenId: nil)
    case "SOL": AssetId(chain: .solana, tokenId: nil)
    case "XRP": AssetId(chain: .solana, tokenId: nil)
    case "BNB": AssetId(chain: .smartChain, tokenId: nil)
    case "PENGU":AssetId(chain: .solana, tokenId: "2zMMhcVQEXDtdE6vsFS7S7D5oUodfJHE8vd1gnBouauv")
    default: nil
    }
}
