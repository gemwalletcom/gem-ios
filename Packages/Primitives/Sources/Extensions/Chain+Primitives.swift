// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Chain {
    public init(id: String) throws {
        if let chain = Chain(rawValue: id) {
            self = chain
        } else {
            throw AnyError("invalid chain id: \(id)")
        }
    }
    
    public var assetId: AssetId {
        return AssetId(chain: self, tokenId: .none)
    }
}

extension Chain: Identifiable {
    public var id: String { rawValue }
}

extension Chain {
    public var stakeChain: StakeChain? {
        StakeChain(rawValue: rawValue)
    }
}
