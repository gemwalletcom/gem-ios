// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct BannerRecord: Codable, FetchableRecord, PersistableRecord  {

    public static var databaseTableName: String = "banners"

    public var id: String
    public var walletId: String?
    public var assetId: String?
    public var event: BannerEvent
    public var state: BannerState

    static let asset = belongsTo(AssetRecord.self).forKey("asset")
    static let wallet = belongsTo(WalletRecord.self).forKey("wallet")
}

extension BannerRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey("id", .text)
                .notNull()
                .indexed()
            $0.column("walletId", .text)
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column("assetId", .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("event", .text)
                .notNull()
            $0.column("state", .text)
                .notNull()
            $0.uniqueKey(["walletId", "assetId", "event"])
        }
    }
}

extension Banner {
    var record: BannerRecord {
        BannerRecord(
            id: id,
            walletId: wallet?.id,
            assetId: asset?.id.identifier,
            event: event,
            state: state
        )
    }
}
