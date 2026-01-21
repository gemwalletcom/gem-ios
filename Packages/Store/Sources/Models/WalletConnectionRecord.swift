// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct WalletConnectionRecord: Codable, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = "wallets_connections"
    
    public enum Columns {
        static let id = Column("id")
        static let sessionId = Column("sessionId")
        static let walletId = Column("walletId")
        static let state = Column("state")
        static let chains = Column("chains")
        static let createdAt = Column("createdAt")
        static let expireAt = Column("expireAt")
        static let appName = Column("appName")
        static let appDescription = Column("appDescription")
        static let appLink = Column("appLink")
        static let appIcon = Column("appIcon")
    }

    public var id: String
    public var sessionId: String
    public var walletId: String
    public var state: WalletConnectionState
    public var chains: [Chain]?
    public var createdAt: Date
    public var expireAt: Date
    
    // metadata
    public var appName: String
    public var appDescription: String
    public var appLink: String
    public var appIcon: String
}

extension WalletConnectionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.sessionId.name, .text)
                .notNull()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.state.name, .text)
                .notNull()
            $0.column(Columns.chains.name, .jsonText)
            $0.column(Columns.createdAt.name, .date)
                .notNull()
            $0.column(Columns.expireAt.name, .date)
                .notNull()
            
            $0.column(Columns.appName.name, .text)
                .notNull()
            $0.column(Columns.appDescription.name, .text)
                .notNull()
            $0.column(Columns.appLink.name, .text)
                .notNull()
            $0.column(Columns.appIcon.name, .text)
                .notNull()
        }
    }
}

extension WalletConnection {
    var record: WalletConnectionRecord {
        WalletConnectionRecord(
            id: session.sessionId,
            sessionId: session.sessionId,
            walletId: wallet.id,
            state: session.state,
            createdAt: Date(),
            expireAt: session.expireAt,
            appName: session.metadata.name,
            appDescription: session.metadata.description,
            appLink: session.metadata.url,
            appIcon: session.metadata.icon
        )
    }
}

extension WalletConnectionRecord {
    var session: WalletConnectionSession {
        WalletConnectionSession(
            id: sessionId,
            sessionId: sessionId,
            state: state,
            chains: chains ?? [],
            createdAt: createdAt,
            expireAt: expireAt,
            metadata: WalletConnectionSessionAppMetadata(
                name: appName,
                description: appDescription,
                url: appLink,
                icon: appIcon
            )
        )
    }
    
    func update(with session: WalletConnectionSession) -> WalletConnectionRecord {
        WalletConnectionRecord(
            id: session.sessionId,
            sessionId: session.sessionId,
            walletId: walletId,
            state: session.state,
            chains: chains ?? [],
            createdAt: createdAt,
            expireAt: session.expireAt,
            appName: session.metadata.name,
            appDescription: session.metadata.description,
            appLink: session.metadata.url,
            appIcon: session.metadata.icon
        )
    }
}
