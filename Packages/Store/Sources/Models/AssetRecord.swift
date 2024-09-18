// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives
import BigInt

public struct AssetRecord: Identifiable, Codable, PersistableRecord, FetchableRecord, TableRecord  {
    
    public static var databaseTableName: String = "assets"
    
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
    
    static let price = hasOne(PriceRecord.self)
    static let details = hasOne(AssetDetailsRecord.self, key: "details")
    static let balance = hasOne(AssetBalanceRecord.self)
    static let account = hasOne(AccountRecord.self, key: "account", using: ForeignKey(["chain"], to: ["chain"]))
    static let priceAlert = hasOne(PriceAlertRecord.self).forKey("priceAlert")
    static let priceAlerts = hasMany(PriceAlertRecord.self).forKey("priceAlerts")
}

extension AssetRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("id", .text)
                .primaryKey()
                .notNull()
            $0.column("chain", .text)
                .notNull()
                .indexed()
            $0.column("tokenId", .text)
                .indexed()
            $0.column("name", .text)
                .notNull()
                .indexed()
            $0.column("symbol", .text)
                .notNull()
                .indexed()
            $0.column("decimals", .numeric)
                .notNull()
            $0.column("type", .text)
                .notNull()
            $0.column("isBuyable", .boolean)
                .defaults(to: false)
            $0.column("isSellable", .boolean) 
                .defaults(to: false)
            $0.column("isSwappable", .boolean)
                .defaults(to: false)
            $0.column("isStakeable", .boolean)
                .defaults(to: false)
            $0.column("rank", .numeric)
                .defaults(to: 0)
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
}

extension AssetRecordInfo {
    var assetData: AssetData {
        return AssetData(
            asset: asset.mapToAsset(),
            balance: balance?.mapToBalance() ?? .zero,
            account: account.mapToAccount(),
            price: price?.mapToPrice(),
            price_alert: priceAlert?.map(),
            details: details?.mapToAssetDetailsInfo(asset: asset),
            metadata: metadata
        )
    }
    
    var metadata: AssetMetaData {
        return AssetMetaData(
            isEnabled: balance?.isEnabled ?? false,
            isBuyEnabled: asset.isBuyable,
            isSwapEnabled: asset.isSwappable,
            isStakeEnabled: asset.isStakeable,
            isPinned: balance?.isPinned ?? false
        )
    }
}
