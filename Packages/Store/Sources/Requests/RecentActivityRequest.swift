// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct RecentActivityRequest: ValueObservationQueryable {
    public static var defaultValue: [Asset] { [] }

    public var walletId: WalletId
    public var limit: Int
    public var types: [RecentActivityType]
    public var filters: [AssetsRequestFilter]

    public init(
        walletId: WalletId,
        limit: Int = 20,
        types: [RecentActivityType] = RecentActivityType.allCases,
        filters: [AssetsRequestFilter] = []
    ) {
        self.walletId = walletId
        self.limit = limit
        self.types = types
        self.filters = filters
    }

    public func fetch(_ db: Database) throws -> [Asset] {
        let recentActivitiesForWallet = AssetRecord.recentActivities
            .filter(RecentActivityRecord.Columns.walletId == walletId.id)
            .filter(types.map(\.rawValue).contains(RecentActivityRecord.Columns.type))

        let maxCreatedAt = recentActivitiesForWallet.max(RecentActivityRecord.Columns.createdAt)

        var request = AssetRecord
            .joining(required: recentActivitiesForWallet)
            .annotated(with: maxCreatedAt.forKey("maxCreatedAt"))

        if filters.contains(where: { $0 == .hasBalance || $0 == .enabledBalance }) {
            request = request.joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId.id))
        }

        return try AssetsRequest.applyFilters(request: request, filters)
            .order(literal: "maxCreatedAt DESC")
            .limit(limit)
            .fetchAll(db)
            .map { $0.mapToAsset() }
    }
}
