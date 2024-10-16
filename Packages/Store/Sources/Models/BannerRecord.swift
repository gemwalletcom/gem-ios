// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct BannerRecord: Codable, FetchableRecord, PersistableRecord  {

    public static let databaseTableName: String = "banners"

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

extension NewBanner {
    var record: BannerRecord {
        let wallet: Wallet? = {
            if let walletId {
                return Wallet(id: walletId, name: "", index: 0, type: .multicoin, accounts: [], order: 0, isPinned: false)
            }
            return .none
        }()
        let asset: Asset? = {
            if let assetId {
                return Asset(id: assetId, name: "", symbol: "", decimals: 0, type: .native)
            }
            return .none
        }()

        return Banner(
            wallet: wallet,
            asset: asset,
            event: event,
            state: state
        ).record
    }
}

public struct NewBanner {
    public let walletId: String?
    public let assetId: AssetId?
    public let event: BannerEvent
    public let state: BannerState

    public init(walletId: String?, assetId: AssetId?, event: BannerEvent, state: BannerState) {
        self.walletId = walletId
        self.assetId = assetId
        self.event = event
        self.state = state
    }
}
