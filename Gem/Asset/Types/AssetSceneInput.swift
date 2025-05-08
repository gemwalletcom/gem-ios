// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct AssetSceneInput: Sendable {
    static let transactionsLimit = 25

    let wallet: Wallet
    let assetId: AssetId

    var assetRequest: AssetRequest
    var transactionsRequest: TransactionsRequest
    var bannersRequest: BannersRequest

    init(wallet: Wallet, assetId: AssetId) {
        self.wallet = wallet
        self.assetId = assetId

        self.assetRequest = AssetRequest(
            walletId: wallet.id,
            assetId: assetId
        )

        self.transactionsRequest = TransactionsRequest(
            walletId: wallet.id,
            type: .asset(assetId: assetId),
            limit: Self.transactionsLimit
        )

        self.bannersRequest = BannersRequest(
            walletId: wallet.id,
            assetId: assetId.identifier,
            chain: assetId.chain.rawValue,
            events: BannerEvent.allCases
        )
    }
}
