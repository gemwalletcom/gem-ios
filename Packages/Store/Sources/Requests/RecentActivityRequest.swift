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
    public var filters: [AssetsRequestFilter]

    public init(
        walletId: String,
        limit: Int = 20,
        filters: [AssetsRequestFilter] = []
    ) {
        self.walletId = walletId
        self.limit = limit
        self.filters = filters
    }

    public func fetch(_ db: Database) throws -> [Asset] {
        let recentActivitiesForWallet = AssetRecord.recentActivities
            .filter(RecentActivityRecord.Columns.walletId == walletId)
        let maxCreatedAt = recentActivitiesForWallet.max(RecentActivityRecord.Columns.createdAt)

        var request = AssetRecord
            .joining(required: recentActivitiesForWallet)
            .annotated(with: maxCreatedAt.forKey("maxCreatedAt"))

        if filters.contains(where: { $0 == .hasBalance || $0 == .enabledBalance }) {
            request = request.joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
        }

        return try AssetsRequest.applyFilters(request: request, filters)
            .order(literal: "maxCreatedAt DESC")
            .limit(limit)
            .fetchAll(db)
            .map { $0.mapToAsset() }
    }
}
