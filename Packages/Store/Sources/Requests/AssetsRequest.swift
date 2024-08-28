import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetsRequest: Queryable {
    public static var defaultValue: [AssetData] { [] }
    
    public var walletID: String
    public var searchBy: String
    public var chains: [String]
    public var filters: [AssetsRequestFilter]
    
    public init(
        walletID: String,
        searchBy: String = "",
        chains: [String],
        filters: [AssetsRequestFilter] = []
    ) {
        self.walletID = walletID
        self.searchBy = searchBy
        self.chains = chains
        self.filters = filters
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[AssetData], Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { $0.map{ $0 } }
            .eraseToAnyPublisher()
    }
    
    func assetBalancesRequest(_ db: Database, searchBy: String) throws -> [AssetData] {
        return try Self.fetchAssets(
            for: walletID,
            searchBy: searchBy,
            filters: filters
        )
        .fetchAll(db).map { $0.assetData }
    }
    
    func assetsRequest(_ db: Database, searchBy: String, excludeAssetIds: [String]) throws -> [AssetData] {
        return try Self.fetchAssetsSearch(
            searchBy: searchBy,
            chains: chains,
            filters: filters,
            excludeAssetIds: excludeAssetIds
        )
        .fetchAll(db).map { $0.assetData }
    }
    
    private func fetch(_ db: Database) throws -> [AssetData] {
        let searchBy = searchBy.trim()
        if filters.contains(.includeNewAssets) {
            let request1 = try assetBalancesRequest(db, searchBy: searchBy)
            let request2 = try assetsRequest(db, searchBy: searchBy, excludeAssetIds: request1.map { $0.asset.id.identifier })
            
            return [request1, request2].flatMap { $0 }
        } else {
            return try assetBalancesRequest(db, searchBy: searchBy)
        }
    }
    
    static func fetchAssets(for walletID: String, searchBy: String, filters: [AssetsRequestFilter])-> QueryInterfaceRequest<AssetRecordInfo>  {
        var request = AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.details)
            .including(optional: AssetRecord.account)
            //.joining(optional: AssetBalanceRecord.filter(Columns.Balance.assetId == assetId.identifier)))
            .filter(literal:
                SQL(stringLiteral: String(format:"%@.walletId = '%@'", AssetBalanceRecord.databaseTableName, walletID))
            )
            .filter(literal:
                SQL(stringLiteral: String(format:"%@.walletId = '%@'", AccountRecord.databaseTableName, walletID))
            )
            .order(literal:
                SQL(stringLiteral: String(format: "%@.fiatValue DESC", AssetBalanceRecord.databaseTableName))
            )
        
        if !searchBy.isEmpty {
            request = Self.applyFilter(request: request, .search(searchBy))
        }
        
        filters.forEach {
            request = Self.applyFilter(request: request, $0)
        }
        return request.asRequest(of: AssetRecordInfo.self)
    }
    
    static func applyFilter(request: QueryInterfaceRequest<AssetRecord>, _ filter: AssetsRequestFilter) -> QueryInterfaceRequest<AssetRecord>  {
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
    
    static func fetchAssetsSearch(
        searchBy: String,
        chains: [String],
        filters: [AssetsRequestFilter],
        excludeAssetIds: [String]
    )-> QueryInterfaceRequest<AssetRecord>  {
        var request = AssetRecord
            .filter(!excludeAssetIds.contains(Columns.Asset.id))
            .order(Columns.Asset.rank.desc)
            .limit(50)
        
        if !searchBy.isEmpty {
            request = Self.applyFilter(request: request, .search(searchBy))
        }
        
        if !chains.isEmpty {
            request = Self.applyFilter(request: request, .chains(chains))
        }
        
        if filters.contains(.buyable) {
            request = Self.applyFilter(request: request, .buyable)
        }
        
        return request.asRequest(of: AssetRecord.self)
    }
}
