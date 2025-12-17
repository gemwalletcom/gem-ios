// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct AssetSceneInput: Sendable {
    private static let transactionsLimit = 25

    public let wallet: Wallet
    public let asset: Asset

    public var assetRequest: ChainAssetRequest
    public var transactionsRequest: TransactionsRequest
    public var bannersRequest: BannersRequest

    public init(wallet: Wallet, asset: Asset) {
        self.wallet = wallet
        self.asset = asset

        self.assetRequest = ChainAssetRequest(
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
