// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives
import BigInt

public struct AssetRecord: Identifiable, Codable, PersistableRecord, FetchableRecord, TableRecord  {
    
    public static let databaseTableName: String = "assets"
    
    enum Columns {
        static let id = Column("id")
        static let rank = Column("rank")
        static let type = Column("type")
        static let chain = Column("chain")
        static let name = Column("name")
        static let symbol = Column("symbol")
        static let decimals = Column("decimals")
        static let tokenId = Column("tokenId")
        static let isBuyable = Column("isBuyable")
        static let isSellable = Column("isSellable")
        static let isSwappable = Column("isSwappable")
        static let isStakeable = Column("isStakeable")
        static let stakingApr = Column("stakingApr")
    }
    
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
            $0.column(Columns.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.chain.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.tokenId.name, .text)
                .indexed()
            $0.column(Columns.name.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.symbol.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.decimals.name, .numeric)
                .notNull()
            $0.column(Columns.type.name, .text)
                .notNull()
            $0.column(Columns.isBuyable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.isSellable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.isSwappable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.isStakeable.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.rank.name, .numeric)
                .defaults(to: 0)
            $0.column(Columns.stakingApr.name, .double)
        }
    }
}

extension Asset {
    var record: AssetRecord {
        AssetRecord(
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
    
    func mapToBasic() -> AssetBasic {
        AssetBasic(
            asset: mapToAsset(),
            properties: AssetProperties(
                isEnabled: true,
                isBuyable: isBuyable,
                isSellable: isSellable,
                isSwapable: isSwappable,
                isStakeable: isStakeable,
                stakingApr: stakingApr
            ),
            score: AssetScore(rank: rank.asInt32)
        )
    }
}

extension PriceRecordInfo {
    var priceData: PriceData {
        PriceData(
            asset: asset.mapToAsset(),
            price: price?.mapToPrice(),
            priceAlerts: priceAlerts.or([]).map { $0.map() },
            market: price?.mapToMarket(),
            links: links.map { $0.link }
        )
    }
}

extension AssetRecordInfo {
    var assetData: AssetData {
        AssetData(
            asset: asset.mapToAsset(),
            balance: balance?.mapToBalance() ?? .zero,
            account: account.mapToAccount(),
            price: price?.mapToPrice(),
            price_alerts: priceAlerts.or([]).compactMap { $0.map() },
            metadata: metadata
        )
    }

    var metadata: AssetMetaData {
        AssetMetaData(
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
