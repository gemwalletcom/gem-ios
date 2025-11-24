// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct RecentActivityRequest: ValueObservationQueryable {
    public static var defaultValue: [AssetData] { [] }

    public var walletId: String
    public var types: [RecentActivityType]
    public var limit: Int

    public init(
        walletId: String,
        types: [RecentActivityType] = RecentActivityType.allCases,
        limit: Int = 20
    ) {
        self.walletId = walletId
        self.types = types
        self.limit = limit
    }

    public func fetch(_ db: Database) throws -> [AssetData] {
        let activities = try RecentActivityRecord
            .filter(RecentActivityRecord.Columns.walletId == walletId)
            .filter(types.map { $0.rawValue }.contains(RecentActivityRecord.Columns.type))
            .order(RecentActivityRecord.Columns.timestamp.desc)
            .limit(limit)
            .fetchAll(db)

        let assetIds = activities.map { $0.assetId.identifier }
        guard !assetIds.isEmpty else { return [] }

        let assetRecords = try AssetRecord
            .including(optional: AssetRecord.account)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.price)
            .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
            .filter(assetIds.contains(AssetRecord.Columns.id))
            .filter(TableAlias(name: AccountRecord.databaseTableName)[AccountRecord.Columns.walletId] == walletId)
            .asRequest(of: AssetRecordInfo.self)
            .fetchAll(db)

        let assetMap = Dictionary(uniqueKeysWithValues: assetRecords.map { ($0.asset.id, $0.assetData) })
        return activities.compactMap { assetMap[$0.assetId.identifier] }
    }
}
