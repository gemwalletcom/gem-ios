import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetsRequest: ValueObservationQueryable {
    public static var defaultValue: [AssetData] { [] }
    
    static let defaultQueryLimit = 50
    
    private let walletID: String

    public var searchBy: String
    public var filters: [AssetsRequestFilter]

    public init(
        walletID: String,
        searchBy: String = "",
        filters: [AssetsRequestFilter] = []
    ) {
        self.walletID = walletID
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
        
        return try fetchAssetsSearch(walletId: walletID, filters: filters)
            .fetchAll(db)
            .map { $0.assetData }
    }
}

// MARK: - Private

extension AssetsRequest {
    
    private func hasPriorityAssets(_ db: Database, query: String) throws -> Bool {
        try AssetSearchRecord
            .filter(Columns.AssetSearch.query == query)
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
                .hidden,
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
                    .filter(Columns.AssetSearch.query == query)
                )
                .order(
                    TableAlias(name: AssetSearchRecord.databaseTableName)[Columns.AssetSearch.priority].ascNullsLast,
                    TableAlias(name: AssetRecord.databaseTableName)[Columns.Asset.rank].desc
                )
            }
            return request
                .filter(
                    Columns.Asset.symbol.like("%%\(query)%%") ||
                    Columns.Asset.name.like("%%\(query)%%") ||
                    Columns.Asset.tokenId.like("%%\(query)%%")
                )
                .order(
                    Columns.Asset.rank.desc
                )
        case .hasBalance:
            return request
                .filter(
                    TableAlias(name: BalanceRecord.databaseTableName)[Columns.Balance.totalAmount] > 0
                )
        case .buyable:
            return request
                .filter(
                    TableAlias(name: AssetRecord.databaseTableName)[Columns.Asset.isBuyable] == true
                )
        case .swappable:
            return request
                .filter(
                    TableAlias(name: AssetRecord.databaseTableName)[Columns.Asset.isSwappable] == true
                )
        case .stakeable:
            return request
                .filter(
                    TableAlias(name: AssetRecord.databaseTableName)[Columns.Asset.isStakeable] == true
                )
        case .enabled:
            return request
                .filter(
                    TableAlias(name: BalanceRecord.databaseTableName)[Columns.Balance.isEnabled] == true
                )
        case .hidden:
            return request
                .filter(
                    TableAlias(name: BalanceRecord.databaseTableName)[Columns.Balance.isHidden] == true
                )
        case .chains(let chains):
            if chains.isEmpty {
                return request
            }
            return request.filter(chains.contains(Columns.Asset.chain))
        case .chainsOrAssets(let chains, let assetIds):
            return request
                .filter(chains.contains(Columns.Asset.chain) || assetIds.contains(Columns.Asset.id))
        case .priceAlerts:
            return request
        }
    }

    private func fetchAssetsSearch(
        walletId: String,
        filters: [AssetsRequestFilter]
    )-> QueryInterfaceRequest<AssetRecordInfo>  {
        let totalValue = (TableAlias(name: BalanceRecord.databaseTableName)[Columns.Balance.totalAmount] * (TableAlias(name: PriceRecord.databaseTableName)[Columns.Price.price] ?? 0))
        let request = AssetRecord
            .including(optional: AssetRecord.account)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.price)
            .joining(optional: AssetRecord.balance
                .filter(Columns.Balance.walletId == walletId)
            )
            .filter(
                TableAlias(name: AccountRecord.databaseTableName)[Columns.Balance.walletId] == walletId
            )
            .order(
                totalValue.desc,
                (totalValue == 0).desc,
                Columns.Asset.rank.desc
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
            .including(all: AssetRecord.priceAlerts)
            .order(Columns.Asset.rank.desc)
            .limit(Self.defaultQueryLimit)
        
        request = Self.applyFilters(request: request, filters)

        return try request
            .asRequest(of: PriceAlertAssetRecordInfo.self)
            .fetchAll(db)
    }
}
