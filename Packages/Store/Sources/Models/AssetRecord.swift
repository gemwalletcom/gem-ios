// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import GRDB
import Primitives
import BigInt

public struct AssetSearchRecord: Codable, PersistableRecord, FetchableRecord, TableRecord  {
    
    public var query: String
    public var assetId: String
    public var priority: Int
    
    public static let databaseTableName: String = "assets_search"
}

extension AssetSearchRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.AssetSearch.query.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.AssetSearch.assetId.name, .text)
                .indexed()
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.AssetSearch.priority.name, .integer)
                .notNull()
            $0.uniqueKey([Columns.AssetSearch.query.name, Columns.AssetSearch.assetId.name])
        }
    }
}

public struct AssetRecord: Identifiable, Codable, PersistableRecord, FetchableRecord, TableRecord  {
    
    public static let databaseTableName: String = "assets"
    
    public var id: String
    public var chain: Chain
    public var tokenId: String
    public var name: String
    public var symbol: String
    public var decimals: Int
    public var type: AssetType
    
    public var isBuyable: Bool
    public var isSellable: Bool
    public var isSwappable: Bool
    public var isStakeable: Bool
    public var rank: Int
    public var stakingApr: Double?
    
    static let price = hasOne(PriceRecord.self)
    static let links = hasMany(AssetLinkRecord.self, key: "links")
    static let balance = hasOne(BalanceRecord.self)
    static let account = hasOne(AccountRecord.self, key: "account", using: ForeignKey(["chain"], to: ["chain"]))
    static let priceAlert = hasOne(PriceAlertRecord.self).forKey("priceAlert")
    static let priceAlerts = hasMany(PriceAlertRecord.self).forKey("priceAlerts")
    static let priorityAssets = hasOne(AssetSearchRecord.self, using: ForeignKey(["assetId"], to: ["id"]))
    
    var priorityAsset: QueryInterfaceRequest<AssetSearchRecord> {
        request(for: AssetRecord.priorityAssets)
    }
}

extension AssetRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.Asset.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.Asset.chain.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.Asset.tokenId.name, .text)
                .indexed()
            $0.column(Columns.Asset.name.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.Asset.symbol.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.Asset.decimals.name, .numeric)
                .notNull()
            $0.column(Columns.Asset.type.name, .text)
                .notNull()
            $0.column(Columns.Asset.isBuyable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.Asset.isSellable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.Asset.isSwappable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.Asset.isStakeable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.Asset.rank.name, .numeric)
                .defaults(to: 0)
            $0.column(Columns.Asset.stakingApr.name, .double)
        }
    }
}

extension Asset {
    var record: AssetRecord {
        return AssetRecord(
            id: id.identifier,
            chain: chain,
            tokenId: tokenId ?? "",
            name: name,
            symbol: symbol,
            decimals: Int(decimals),
            type: type,
            isBuyable: false,
            isSellable: false,
            isSwappable: false,
            isStakeable: false,
            rank: 0
        )
    }
}

extension AssetRecord {
    func mapToAsset() -> Asset {
        let tokenId = tokenId.count == 0 ? nil : tokenId
        return Asset(
            id: AssetId(chain: chain, tokenId: tokenId),
            name: name,
            symbol: symbol,
            decimals: decimals.asInt32,
            type: type
        )
    }
    
    func mapToEmptyAssetData() -> AssetData {
        AssetData(
            asset: mapToAsset(),
            balance: .zero,
            account: .init(
                chain: chain,
                address: .empty,
                derivationPath: .empty,
                extendedPublicKey: nil
            ),
            price: nil,
            price_alert: nil,
            metadata: AssetMetaData(
                isEnabled: true,
                isBuyEnabled: isBuyable,
                isSellEnabled: isSellable,
                isSwapEnabled: isSwappable,
                isStakeEnabled: isStakeable,
                isPinned: false,
                isActive: false,
                stakingApr: stakingApr
            )
        )
    }
}

extension PriceRecordInfo {
    var priceData: PriceData {
        return PriceData(
            asset: asset.mapToAsset(),
            price: price?.mapToPrice(),
            priceAlert: priceAlert?.map(),
            market: price?.mapToMarket(),
            links: links.map { $0.link }
        )
    }
}

extension AssetRecordInfo {
    var assetData: AssetData {
        return AssetData(
            asset: asset.mapToAsset(),
            balance: balance?.mapToBalance() ?? .zero,
            account: account.mapToAccount(),
            price: price?.mapToPrice(),
            price_alert: priceAlert?.map(),
            metadata: metadata
        )
    }

    var metadata: AssetMetaData {
        return AssetMetaData(
            isEnabled: balance?.isEnabled ?? false,
            isBuyEnabled: asset.isBuyable,
            isSellEnabled: asset.isSellable,
            isSwapEnabled: asset.isSwappable,
            isStakeEnabled: asset.isStakeable,
            isPinned: balance?.isPinned ?? false,
            isActive: balance?.isActive ?? true,
            stakingApr: asset.stakingApr
        )
    }
}

extension AssetBasic {
    var record: AssetRecord {
        AssetRecord(
            id: asset.id.identifier,
            chain: asset.chain,
            tokenId: asset.tokenId ?? "",
            name: asset.name,
            symbol: asset.symbol,
            decimals: Int(asset.decimals),
            type: asset.type,
            isBuyable: properties.isBuyable,
            isSellable: properties.isSellable,
            isSwappable: properties.isSwapable,
            isStakeable: properties.isStakeable,
            rank: score.rank.asInt,
            stakingApr: properties.stakingApr
        )
    }
}
