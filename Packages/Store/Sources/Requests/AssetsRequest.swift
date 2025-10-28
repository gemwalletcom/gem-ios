import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetsRequest: ValueObservationQueryable {
    public static var defaultValue: [AssetData] { [] }
    
    static let defaultQueryLimit = 100
    
    public var walletId: String
    public var searchBy: String
    public var filters: [AssetsRequestFilter]

    public init(
        walletId: String,
        searchBy: String = "",
        filters: [AssetsRequestFilter] = []
    ) {
        self.walletId = walletId
        self.searchBy = searchBy
        self.filters = filters
    }

    public func fetch(_ db: Database) throws -> [AssetData] {
        let searchBy = searchBy.trim()
        
        let filters = if searchBy.isEmpty {
            filters
        } else {
            filters + [.search(searchBy, hasPriorityAssets: try hasPriorityAssets(db, query: searchBy))]
        }
        
        if filters.contains(.priceAlerts) {
            return try fetchAllAssetRecordsRequest(db, filters: filters)
                .map { $0.mapToEmptyAssetData() }
        }
        
        return try fetchAssetsSearch(walletId: walletId, filters: filters)
            .fetchAll(db)
            .map { $0.assetData }
    }
}

// MARK: - Private

extension AssetsRequest {
    
    private func hasPriorityAssets(_ db: Database, query: String) throws -> Bool {
        try AssetSearchRecord
            .filter(AssetSearchRecord.Columns.query == query)
            .fetchCount(db) > 0
    }
    
    static private func applyFilters(request: QueryInterfaceRequest<AssetRecord>, _ filters: [AssetsRequestFilter]) -> QueryInterfaceRequest<AssetRecord> {
        var request: QueryInterfaceRequest<AssetRecord> = request
        filters.forEach {
            switch $0 {
            case .buyable,
                .swappable,
                .stakeable,
                .chains,
                .chainsOrAssets,
                .search,
                .enabled,
                .hasBalance,
                .priceAlerts:
                request = Self.applyFilter(request: request, $0)
            }
        }
        return request
    }

    static private func applyFilter(request: QueryInterfaceRequest<AssetRecord>, _ filter: AssetsRequestFilter) -> QueryInterfaceRequest<AssetRecord>  {
        switch filter {
        case .search(let query, let hasPriorityAssets):
            if hasPriorityAssets {
                return request.joining(required: AssetRecord.priorityAssets
                    .filter(AssetSearchRecord.Columns.query == query)
                )
                .order(
                    TableAlias(name: AssetSearchRecord.databaseTableName)[AssetSearchRecord.Columns.priority].ascNullsLast,
                    TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.rank].desc
                )
            }
            return request
                .filter(
                    AssetRecord.Columns.symbol.like("%%\(query)%%") ||
                    AssetRecord.Columns.name.like("%%\(query)%%") ||
                    AssetRecord.Columns.tokenId.like("%%\(query)%%")
                )
                .order(
                    AssetRecord.Columns.rank.desc
                )
        case .hasBalance:
            return request
                .filter(
                    TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.totalAmount] > 0
                )
        case .buyable:
            return request
                .filter(
                    TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.isBuyable] == true
                )
        case .swappable:
            return request
                .filter(
                    TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.isSwappable] == true
                )
        case .stakeable:
            return request
                .filter(
                    TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.isStakeable] == true
                )
        case .enabled:
            return request
                .filter(
                    TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.isEnabled] == true
                )
        case .chains(let chains):
            if chains.isEmpty {
                return request
            }
            return request.filter(chains.contains(AssetRecord.Columns.chain))
        case .chainsOrAssets(let chains, let assetIds):
            return request
                .filter(chains.contains(AssetRecord.Columns.chain) || assetIds.contains(AssetRecord.Columns.id))
        case .priceAlerts:
            return request
        }
    }

    private func fetchAssetsSearch(
        walletId: String,
        filters: [AssetsRequestFilter]
    )-> QueryInterfaceRequest<AssetRecordInfo>  {
        let totalValue = (TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.totalAmount] * (TableAlias(name: PriceRecord.databaseTableName)[PriceRecord.Columns.price] ?? 0))
        let request = AssetRecord
            .filter(AssetRecord.Columns.isEnabled == true)
            .including(optional: AssetRecord.account)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.price)
            .joining(optional: AssetRecord.balance
                .filter(BalanceRecord.Columns.walletId == walletId)
            )
            .filter(
                TableAlias(name: AccountRecord.databaseTableName)[BalanceRecord.Columns.walletId] == walletId
            )
            .order(
                TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.isPinned].desc,
                TableAlias(name: BalanceRecord.databaseTableName)[BalanceRecord.Columns.isEnabled].desc,
                totalValue.desc,
                (totalValue == 0).desc,
                AssetRecord.Columns.rank.desc
            )
            .limit(Self.defaultQueryLimit)
        
        return Self.applyFilters(request: request, filters)
            .asRequest(of: AssetRecordInfo.self)
    }
}

// Specific case for the price alerts scene:
// This is necessary because watch-only wallets do not create accounts for other networks.
// On the price alerts screen, we fetch all assets and fill them with empty data.
extension AssetsRequest {
    private func fetchAllAssetRecordsRequest(
        _ db: Database,
        filters: [AssetsRequestFilter]
    ) throws -> [PriceAlertAssetRecordInfo] {
        var request = AssetRecord
            .filter(AssetRecord.Columns.isEnabled == true)
            .including(all: AssetRecord.priceAlerts)
            .including(optional: AssetRecord.price)
            .order(AssetRecord.Columns.rank.desc)
            .limit(Self.defaultQueryLimit)
        
        request = Self.applyFilters(request: request, filters)

        return try request
            .asRequest(of: PriceAlertAssetRecordInfo.self)
            .fetchAll(db)
    }
}
