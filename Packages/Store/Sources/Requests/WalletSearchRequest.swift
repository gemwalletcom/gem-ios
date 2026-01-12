// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import Foundation
import GRDB
import GRDBQuery
import Primitives

public struct WalletSearchResult: Equatable, Sendable {
    public let assets: [AssetData]
    public let perpetuals: [PerpetualData]

    public static let empty = WalletSearchResult(assets: [], perpetuals: [])
}

public struct WalletSearchRequest: ValueObservationQueryable {
    public static var defaultValue: WalletSearchResult { .empty }

    private static let defaultLimit = 10
    private static let searchLimit = 20

    public var walletId: String
    public var searchBy: String
    public var tag: String?

    public init(walletId: String, searchBy: String = "", tag: String? = nil) {
        self.walletId = walletId
        self.searchBy = searchBy
        self.tag = tag
    }

    public func fetch(_ db: Database) throws -> WalletSearchResult {
        let query = searchBy.trim()
        let searchKey = tag.map { query.isEmpty ? "tag:\($0)" : query } ?? query
        let isSearching = searchKey.isNotEmpty
        let limit = isSearching ? Self.searchLimit : Self.defaultLimit

        return WalletSearchResult(
            assets: try fetchAssets(db, query: query, searchKey: searchKey, limit: limit, hasPriority: isSearching && hasPriority(db, searchKey: searchKey, column: SearchRecord.Columns.assetId)),
            perpetuals: tag == nil ? try fetchPerpetuals(db, query: query, searchKey: searchKey, limit: limit, hasPriority: isSearching && hasPriority(db, searchKey: searchKey, column: SearchRecord.Columns.perpetualId)) : []
        )
    }
}

// MARK: - Private

extension WalletSearchRequest {
    private func hasPriority(_ db: Database, searchKey: String, column: Column) throws -> Bool {
        try SearchRecord
            .filter(SearchRecord.Columns.query == searchKey)
            .filter(column != nil)
            .limit(1)
            .fetchOne(db) != nil
    }

    private func fetchAssets(_ db: Database, query: String, searchKey: String, limit: Int, hasPriority: Bool) throws -> [AssetData] {
        var request = AssetRecord
            .including(optional: AssetRecord.account)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.price)
            .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
            .filter(TableAlias(name: AccountRecord.databaseTableName)[AccountRecord.Columns.walletId] == walletId)

        if hasPriority {
            request = request
                .joining(required: AssetRecord.search.filter(SearchRecord.Columns.query == searchKey))
                .order(TableAlias(name: SearchRecord.databaseTableName)[SearchRecord.Columns.priority].ascNullsLast, AssetRecord.Columns.rank.desc)
        } else {
            request = request
                .filter(AssetRecord.Columns.symbol.like("%%\(query)%%") || AssetRecord.Columns.name.like("%%\(query)%%") || AssetRecord.Columns.tokenId.like("%%\(query)%%"))
                .order(
                    TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.isPinned].desc,
                    TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.isEnabled].desc,
                    (TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.totalAmount] * (TableAlias(name: PriceRecord.databaseTableName)[PriceRecord.Columns.price] ?? 0)).desc,
                    AssetRecord.Columns.rank.desc
                )
        }

        return try request.limit(limit).asRequest(of: AssetRecordInfo.self).fetchAll(db).map(\.assetData)
    }

    private func fetchPerpetuals(_ db: Database, query: String, searchKey: String, limit: Int, hasPriority: Bool) throws -> [PerpetualData] {
        var request = PerpetualRecord.including(required: PerpetualRecord.asset)

        if hasPriority {
            request = request
                .joining(required: PerpetualRecord.search.filter(SearchRecord.Columns.query == searchKey))
                .order(TableAlias(name: SearchRecord.databaseTableName)[SearchRecord.Columns.priority].ascNullsLast, PerpetualRecord.Columns.volume24h.desc)
        } else {
            request = request
                .filter(PerpetualRecord.Columns.name.like("%%\(query)%%") || TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.symbol].like("%%\(query)%%"))
                .order(PerpetualRecord.Columns.volume24h.desc)
        }

        return try request.limit(limit).asRequest(of: PerpetualInfo.self).fetchAll(db).map { $0.mapToPerpetualData() }
    }
}
