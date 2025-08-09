// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct BannersRequest: ValueObservationQueryable {
    public static var defaultValue: [Banner] { [] }

    private let walletId: String
    private let events: [BannerEvent]
    private let filters: [BannersRequestFilter]

    public init(
        walletId: String,
        events: [BannerEvent],
        filters: [BannersRequestFilter] = []
    ) {
        self.walletId = walletId
        self.events = events
        self.filters = filters
    }

    public func fetch(_ db: Database) throws -> [Banner] {
        var query = BannerRecord
            .including(optional: BannerRecord.asset)
            .including(optional: BannerRecord.chain)
            .including(optional: BannerRecord.wallet)
            .filter(events.map { $0.rawValue }.contains(BannerRecord.Columns.event))
            .filter(BannerRecord.Columns.state != BannerState.cancelled.rawValue)
            .filter(BannerRecord.Columns.walletId == walletId || BannerRecord.Columns.walletId == nil)

        for filter in filters {
            try applyFilter(query: &query, filter: filter, db: db)
        }

        return try query
            .asRequest(of: BannerInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToBanner() }
    }
    
    // MARK: - Private
    
    private func applyFilter(
        query: inout QueryInterfaceRequest<BannerRecord>,
        filter: BannersRequestFilter,
        db: Database
    ) throws {
        switch filter {
        case .asset(let assetId):
            query = query.filter(
                BannerRecord.Columns.assetId == assetId.identifier || 
                BannerRecord.Columns.chain == assetId.chain.rawValue
            )
            
        case .excludeActiveStaking:
            query = query
                .joining(optional: BannerRecord.asset
                    .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
                )
                .filter(
                    BannerRecord.Columns.event != BannerEvent.stake.rawValue || 
                    TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.stakedAmount] <= 0 ||
                    TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.stakedAmount] == nil
                )
        }
    }
}
