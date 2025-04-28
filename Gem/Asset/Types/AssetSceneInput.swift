// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct AssetSceneInput {

    let walletId: WalletId
    let assetId: AssetId

    static let transactionsLimit = 25

    var assetRequest: AssetRequest {
        return AssetRequest(walletId: walletId.id, assetId: assetId)
    }
    
    var transactionsRequest: TransactionsRequest {
        return TransactionsRequest(walletId: walletId.id, type: .asset(assetId: assetId), limit: Self.transactionsLimit)
    }

    var bannersRequest: BannersRequest {
        return BannersRequest(
            walletId: walletId.id,
            assetId: assetId.identifier,
            chain: assetId.chain.rawValue,
            events: BannerEvent.allCases
        )
    }
}
