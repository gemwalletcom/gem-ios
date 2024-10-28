// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct BannerRecord: Codable, FetchableRecord, PersistableRecord  {

    public static let databaseTableName: String = "banners"

    public var id: String
    public var walletId: String?
    public var assetId: String?
    public var chain: String?
    public var event: BannerEvent
    public var state: BannerState

    static let asset = belongsTo(AssetRecord.self, key: "asset", using: ForeignKey(["assetId"], to: ["id"]))
    static let chain = belongsTo(AssetRecord.self, key: "chain", using: ForeignKey(["chain"], to: ["id"]))
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
            $0.column("chain", .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("event", .text)
                .notNull()
            $0.column("state", .text)
                .notNull()
            $0.uniqueKey(["walletId", "assetId", "chain", "event"])
        }
    }
}

extension Banner {
    var record: BannerRecord {
        BannerRecord(
            id: id,
            walletId: wallet?.id,
            assetId: asset?.id.identifier,
            chain: chain?.id,
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
            chain: chain,
            event: event,
            state: state
        ).record
    }
}

public struct NewBanner {
    public let walletId: String?
    public let assetId: AssetId?
    public var chain: Chain?
    public let event: BannerEvent
    public let state: BannerState

    public init(
        walletId: String? = .none,
        assetId: AssetId? = .none,
        chain: Chain? = .none,
        event: BannerEvent,
        state: BannerState
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.chain = chain
        self.event = event
        self.state = state
    }
}

extension NewBanner {
    public static func stake(assetId: AssetId) -> NewBanner {
        return NewBanner(
            assetId: assetId,
            event: .stake,
            state: .active
        )
    }
    
    public static func accountActivation(assetId: AssetId) -> NewBanner {
        return NewBanner(
            assetId: assetId,
            event: .accountActivation,
            state: .active
        )
    }
    
    public static func accountBlockedMultiSignature(walletId: WalletId, chain: Chain) -> NewBanner {
        return NewBanner(
            walletId: walletId.id,
            chain: chain,
            event: .accountBlockedMultiSignature,
            state: .alwaysActive
        )
    }
}
