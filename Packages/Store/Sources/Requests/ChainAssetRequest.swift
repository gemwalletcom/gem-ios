// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct ChainAssetRequest: ValueObservationQueryable {
    public static var defaultValue: ChainAssetData { .empty }

    public var assetRequest: AssetRequest
    public var feeAssetRequest: AssetRequest

    public init(walletId: String, assetId: AssetId) {
        self.assetRequest = AssetRequest(walletId: walletId, assetId: assetId)
        self.feeAssetRequest = AssetRequest(walletId: walletId, assetId: assetId.chain.assetId)
    }

    public func fetch(_ db: Database) throws -> ChainAssetData {
        ChainAssetData(
            assetData: try assetRequest.fetch(db),
            feeAssetData: try feeAssetRequest.fetch(db)
        )
    }
}

extension ChainAssetData {
    public static let empty = ChainAssetData(
        assetData: .empty,
        feeAssetData: .empty
    )
}
