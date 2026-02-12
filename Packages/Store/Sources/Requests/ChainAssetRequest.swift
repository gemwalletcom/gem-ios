// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ChainAssetRequest: DatabaseQueryable {

    public var assetRequest: AssetRequest
    public var feeAssetRequest: AssetRequest

    public init(walletId: WalletId, assetId: AssetId) {
        self.assetRequest = AssetRequest(walletId: walletId, assetId: assetId)
        self.feeAssetRequest = AssetRequest(walletId: walletId, assetId: assetId.chain.assetId)
    }

    public func fetch(_ db: Database) throws -> ChainAssetData {
        if assetRequest.assetId == feeAssetRequest.assetId {
            let assetData = try assetRequest.fetch(db)
            return ChainAssetData(
                assetData: assetData,
                feeAssetData: assetData
            )
        }
        return ChainAssetData(
            assetData: try assetRequest.fetch(db),
            feeAssetData: try feeAssetRequest.fetch(db)
        )
    }
}

extension ChainAssetRequest: Equatable {}
