import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetsRequest: ValueObservationQueryable {
    public static var defaultValue: [AssetData] { [] }
    
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

        if filters.contains(.includeNewAssets) {
            let request1 = try assetBalancesRequest(db)
            let request2 = try assetsRequest(db, searchBy: searchBy, excludeAssetIds: request1.map { $0.asset.id.identifier })

            return [request1, request2].flatMap { $0 }
        }
        return try assetBalancesRequest(db)
    }

    func fetchAssets(filters: [AssetsRequestFilter])-> QueryInterfaceRequest<AssetRecordInfo>  {
        var request = AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.details)
            .including(optional: AssetRecord.account)
            .joining(required: AssetRecord.balance
                .filter(Columns.Balance.walletId == walletID)
                .order(Columns.Balance.fiatValue.desc)
            )
            .joining(required: AssetRecord.account.filter(Columns.Account.walletId == walletID))

        if !searchBy.isEmpty {
            request = Self.applyFilter(request: request, .search(searchBy))
        }

        filters.forEach {
            request = Self.applyFilter(request: request, $0)
        }
        return request.asRequest(of: AssetRecordInfo.self)
    }
}

// MARK: - Private

extension AssetsRequest {
    private func assetBalancesRequest(_ db: Database) throws -> [AssetData] {
        try fetchAssets(filters: filters)
            .fetchAll(db).map { $0.assetData }
    }

    private func assetsRequest(_ db: Database, searchBy: String, excludeAssetIds: [String]) throws -> [AssetData] {
        try Self.fetchAssetsSearch(
            walletId: walletID,
            searchBy: searchBy,
            filters: filters,
            excludeAssetIds: excludeAssetIds
        )
        .fetchAll(db).map { $0.assetData }
    }

    static private func applyFilter(request: QueryInterfaceRequest<AssetRecord>, _ filter: AssetsRequestFilter) -> QueryInterfaceRequest<AssetRecord>  {
        switch filter {
        case .search(let name):
            return request
                .filter(
                    Columns.Asset.symbol.like("%%\(name)%%") ||
                    Columns.Asset.name.like("%%\(name)%%") ||
                    Columns.Asset.tokenId.like("%%\(name)%%")
                )
        case .hasFiatValue:
            return request
                .filter(
                    SQL(stringLiteral: String(format: "%@.fiatValue > 0", AssetBalanceRecord.databaseTableName) )
                )
        case .hasBalance:
            return request
                .filter(
                    SQL(stringLiteral: String(format: "%@.total > 0", AssetBalanceRecord.databaseTableName) )
                )
        case .buyable:
            return request
                .filter(
                    SQL(stringLiteral:  String(format: "%@.isBuyable == true", AssetRecord.databaseTableName))
                )
        case .swappable:
            return request
                .filter(
                    SQL(stringLiteral:  String(format: "%@.isSwappable == true", AssetRecord.databaseTableName))
                )
        case .stakeable:
            return request
                .filter(
                    SQL(stringLiteral:  String(format: "%@.isStakeable == true", AssetRecord.databaseTableName))
                )
        case .enabled:
            return request
                .filter(
                    SQL(stringLiteral:  String(format: "%@.isEnabled == true", AssetBalanceRecord.databaseTableName))
                )
        case .hidden:
            return request
                .filter(
                    SQL(stringLiteral:  String(format: "%@.isHidden == true", AssetBalanceRecord.databaseTableName))
                )
        case .chains(let chains):
            if chains.isEmpty {
                return request
            }
            return request.filter(chains.contains(Columns.Asset.chain))
        case .includePinned(let value):
            return request
                .filter(
                    SQL(stringLiteral:  String(format: "%@.isPinned == %d", AssetBalanceRecord.databaseTableName, value))
                )
        case .includeNewAssets:
            return request
        }
    }

    static private func fetchAssetsSearch(
        walletId: String,
        searchBy: String,
        filters: [AssetsRequestFilter],
        excludeAssetIds: [String]
    )-> QueryInterfaceRequest<AssetRecordInfo>  {
        var request = AssetRecord
            .including(optional: AssetRecord.account)
            .filter(!excludeAssetIds.contains(Columns.Asset.id))
            .filter(literal:
                SQL(stringLiteral: String(format:"%@.walletId = '%@'", AccountRecord.databaseTableName, walletId))
            )
            .order(Columns.Asset.rank.asc)
            .limit(50)

        if !searchBy.isEmpty {
            request = Self.applyFilter(request: request, .search(searchBy))
        }

        //Ignoring some filters as they only applied to balances table
        filters.forEach {
            switch $0 {
            case .buyable,
                .swappable,
                .stakeable,
                .chains:
                request = Self.applyFilter(request: request, $0)
            case .hasFiatValue,
                .hasBalance,
                .enabled,
                .hidden,
                .includePinned,
                .includeNewAssets,
                .search:
                break
            }
        }

        return request.asRequest(of: AssetRecordInfo.self)
    }
}
