// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct AssetSceneInput: Sendable {
    static let transactionsLimit = 25

    let wallet: Wallet
    let asset: Asset

    var assetRequest: AssetRequest
    var transactionsRequest: TransactionsRequest
    var bannersRequest: BannersRequest

    init(wallet: Wallet, asset: Asset) {
        self.wallet = wallet
        self.asset = asset

        self.assetRequest = AssetRequest(
            walletId: wallet.id,
            assetId: asset.id
        )

        self.transactionsRequest = TransactionsRequest(
            walletId: wallet.id,
            type: .asset(assetId: asset.id),
            limit: Self.transactionsLimit
        )

        self.bannersRequest = BannersRequest(
            walletId: wallet.id,
            assetId: asset.id.identifier,
            chain: asset.id.chain.rawValue,
            events: BannerEvent.allCases
        )
    }
}
