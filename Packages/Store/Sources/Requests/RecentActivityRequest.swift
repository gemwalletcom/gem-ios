// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct RecentActivityRequest: ValueObservationQueryable {
    public static var defaultValue: [AssetData] { [] }

    public var walletId: String
    public var limit: Int

    public init(
        walletId: String,
        limit: Int = 20
    ) {
        self.walletId = walletId
        self.limit = limit
    }

    public func fetch(_ db: Database) throws -> [AssetData] {
        let recentActivitiesForWallet = AssetRecord.recentActivities
            .filter(RecentActivityRecord.Columns.walletId == walletId)
        let maxTimestamp = recentActivitiesForWallet.max(RecentActivityRecord.Columns.timestamp)

        return try AssetRecord
            .joining(required: recentActivitiesForWallet)
            .including(optional: AssetRecord.account)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.price)
            .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
            .filter(TableAlias(name: AccountRecord.databaseTableName)[AccountRecord.Columns.walletId] == walletId)
            .annotated(with: maxTimestamp.forKey("maxTimestamp"))
            .order(literal: "maxTimestamp DESC")
            .limit(limit)
            .asRequest(of: AssetRecordInfo.self)
            .fetchAll(db)
            .map { $0.assetData }
    }
}
