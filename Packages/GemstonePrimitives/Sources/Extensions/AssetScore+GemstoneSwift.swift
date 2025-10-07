// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import func Gemstone.assetDefaultRank

extension AssetScore {
    
    // default score of an asset, not assigned
    public static let defaultScore = 15
    
    public static func defaultScore(chain: Chain) -> AssetScore {
        return AssetScore(
            rank: AssetScore.defaultRank(chain: chain).asInt32
        )
    }
    
    // from 0 to 100. anything below is 0 is not good
    public static func defaultRank(chain: Chain) -> Int {
        Gemstone.assetDefaultRank(chain: chain.rawValue).asInt
    }
}
