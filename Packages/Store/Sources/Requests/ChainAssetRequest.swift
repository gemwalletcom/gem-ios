// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct ChainAssetRequest: ValueObservationQueryable {
    public static var defaultValue: ChainAssetData { .empty }

    public var assetId: AssetId
    private let walletId: String

    public init(walletId: String, assetId: AssetId) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> ChainAssetData {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.account)
            .including(all: AssetRecord.priceAlerts)
            .including(required: AssetRecord.nativeAsset
                .forKey("nativeAssetInfo")
                .including(optional: AssetRecord.balance.forKey("nativeBalance")))
            .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
            .joining(optional: AssetRecord.account.filter(AccountRecord.Columns.walletId == walletId))
            .joining(optional: AssetRecord.nativeAsset
                .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId)))
            .filter(AssetRecord.Columns.id == assetId.identifier)
            .asRequest(of: ChainAssetRecordInfo.self)
            .fetchOne(db)?
            .chainAssetData ?? .empty
    }
}

extension ChainAssetData {
    public static let empty = ChainAssetData(
        assetData: .empty,
        nativeAssetData: .empty
    )
}
