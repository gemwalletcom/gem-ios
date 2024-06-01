// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct AssetSceneInput {
    let assetId: AssetId
    let wallet: Wallet
    
    static let transactionsLimit = 10
    
    var assetRequest: AssetRequest {
        return AssetRequest(walletId: wallet.id, assetId: assetId.identifier)
    }
    
    var transactionsRequest: TransactionsRequest {
        return TransactionsRequest(walletId: wallet.id, type: .asset(assetId: assetId), limit: Self.transactionsLimit)
    }
}
