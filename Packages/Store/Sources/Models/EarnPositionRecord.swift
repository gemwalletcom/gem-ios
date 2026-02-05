// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct EarnPositionRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "earn_positions"

    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let assetId = Column("assetId")
        static let providerId = Column("providerId")
        static let state = Column("state")
        static let balance = Column("balance")
        static let shares = Column("shares")
        static let rewards = Column("rewards")
        static let unlockDate = Column("unlockDate")
        static let positionId = Column("positionId")
    }

    public var id: String
    public var walletId: String
    public var assetId: AssetId
    public var providerId: String
    public var state: String
    public var balance: String
    public var shares: String
    public var rewards: String
    public var unlockDate: Date?
    public var positionId: String

    public init(
        id: String,
        walletId: String,
        assetId: AssetId,
        providerId: String,
        state: String,
        balance: String,
        shares: String,
        rewards: String,
        unlockDate: Date?,
        positionId: String
    ) {
        self.id = id
        self.walletId = walletId
        self.assetId = assetId
        self.providerId = providerId
        self.state = state
        self.balance = balance
        self.shares = shares
        self.rewards = rewards
        self.unlockDate = unlockDate
        self.positionId = positionId
    }

    static let wallet = belongsTo(WalletRecord.self, key: "wallet")
    static let asset = belongsTo(AssetRecord.self, key: "asset", using: ForeignKey(["assetId"], to: ["id"]))
    static let provider = belongsTo(EarnProviderRecord.self, key: "provider", using: ForeignKey(["providerId"], to: ["id"]))
}

extension EarnPositionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.providerId.name, .text)
                .notNull()
                .indexed()
                .references(EarnProviderRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.state.name, .text)
                .notNull()
                .defaults(to: "active")
            $0.column(Columns.balance.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.shares.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.rewards.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.unlockDate.name, .datetime)
            $0.column(Columns.positionId.name, .text)
                .notNull()
        }
    }
}

extension EarnPositionRecord {
    public func earnPosition(provider: EarnProvider) -> EarnPosition? {
        guard let state = EarnPositionState(rawValue: state) else {
            return nil
        }
        let base = EarnPositionBase(
            assetId: assetId,
            state: state,
            balance: balance,
            shares: shares,
            rewards: rewards,
            unlockDate: unlockDate,
            positionId: positionId,
            providerId: provider.id
        )
        return EarnPosition(base: base, provider: provider, price: nil)
    }
}

extension EarnPositionBase {
    public func record(walletId: String) -> EarnPositionRecord {
        EarnPositionRecord(
            id: "\(walletId)_\(positionId)",
            walletId: walletId,
            assetId: assetId,
            providerId: EarnProvider.recordId(chain: assetId.chain, providerId: providerId),
            state: state.rawValue,
            balance: balance,
            shares: shares,
            rewards: rewards,
            unlockDate: unlockDate,
            positionId: positionId
        )
    }
}
