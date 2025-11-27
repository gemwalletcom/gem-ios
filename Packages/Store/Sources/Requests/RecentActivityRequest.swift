// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct RecentActivityRequest: ValueObservationQueryable {
    public static var defaultValue: [Asset] { [] }

    public var walletId: String
    public var limit: Int

    public init(
        walletId: String,
        limit: Int = 20
    ) {
        self.walletId = walletId
        self.limit = limit
    }

    public func fetch(_ db: Database) throws -> [Asset] {
        let recentActivitiesForWallet = AssetRecord.recentActivities
            .filter(RecentActivityRecord.Columns.walletId == walletId)
        let maxCreatedAt = recentActivitiesForWallet.max(RecentActivityRecord.Columns.createdAt)

        return try AssetRecord
            .joining(required: recentActivitiesForWallet)
            .annotated(with: maxCreatedAt.forKey("maxCreatedAt"))
            .order(literal: "maxCreatedAt DESC")
            .limit(limit)
            .fetchAll(db)
            .map { $0.mapToAsset() }
    }
}
