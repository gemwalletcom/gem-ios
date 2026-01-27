// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct BannerRecord: Codable, FetchableRecord, PersistableRecord  {

    public static let databaseTableName: String = "banners"
    
    public enum Columns {
        static let id = Column("id")
        static let state = Column("state")
        static let event = Column("event")
        static let assetId = Column("assetId")
        static let chain = Column("chain")
        static let walletId = Column("walletId")
    }

    public var id: String
    public var walletId: String?
    public var assetId: AssetId?
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
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.walletId.name, .text)
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.assetId.name, .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.chain.name, .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.event.name, .text)
                .notNull()
            $0.column(Columns.state.name, .text)
                .notNull()
            $0.uniqueKey(
                [
                    Columns.walletId.name,
                    Columns.assetId.name,
                    Columns.chain.name,
                    Columns.event.name
                ]
            )
        }
    }
}

extension Banner {
    var record: BannerRecord {
        BannerRecord(
            id: id,
            walletId: wallet?.id,
            assetId: asset?.id,
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
                return Wallet(id: walletId, externalId: nil, name: "", index: 0, type: .multicoin, accounts: [], order: 0, isPinned: false, imageUrl: nil, source: .create)
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
        NewBanner(
            assetId: assetId,
            event: .stake,
            state: .active
        )
    }

    public static func accountActivation(assetId: AssetId) -> NewBanner {
        NewBanner(
            assetId: assetId,
            event: .accountActivation,
            state: .active
        )
    }

    public static func accountBlockedMultiSignature(walletId: WalletId, chain: Chain) -> NewBanner {
        NewBanner(
            walletId: walletId.id,
            chain: chain,
            event: .accountBlockedMultiSignature,
            state: .alwaysActive
        )
    }

    public static func onboarding(walletId: WalletId) -> NewBanner {
        NewBanner(
            walletId: walletId.id,
            event: .onboarding,
            state: .active
        )
    }

    public static func tradePerpetuals(assetId: AssetId) -> NewBanner {
        NewBanner(
            assetId: assetId,
            event: .tradePerpetuals,
            state: .active
        )
    }
}
