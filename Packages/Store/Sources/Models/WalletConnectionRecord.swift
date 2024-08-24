// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct WalletConnectionRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static var databaseTableName: String = "wallets_connections"

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
    public var redirectNative: String?
    public var redirectUniversal: String?
}

extension WalletConnectionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("id", .text)
                .primaryKey()
                .notNull()
            $0.column("sessionId", .text)
                .notNull()
            $0.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column("state", .text)
                .notNull()
            $0.column("chains", .jsonText)
            $0.column("createdAt", .date)
                .notNull()
            $0.column("expireAt", .date)
                .notNull()
            
            $0.column("appName", .text)
                .notNull()
            $0.column("appDescription", .text)
                .notNull()
            $0.column("appLink", .text)
                .notNull()
            $0.column("appIcon", .text)
                .notNull()
            $0.column("redirectNative", .text)
            $0.column("redirectUniversal", .text)
        }
    }
}

extension WalletConnection {
    var record: WalletConnectionRecord {
        WalletConnectionRecord(
            id: session.id,
            sessionId: session.sessionId,
            walletId: wallet.id,
            state: session.state,
            createdAt: Date(),
            expireAt: session.expireAt,
            appName: session.metadata.name,
            appDescription: session.metadata.description,
            appLink: session.metadata.url,
            appIcon: session.metadata.icon,
            redirectNative: session.metadata.redirectNative,
            redirectUniversal: session.metadata.redirectUniversal
        )
    }
}

extension WalletConnectionRecord {
    var session: WalletConnectionSession {
        WalletConnectionSession(
            id: id, 
            sessionId: sessionId,
            state: state,
            chains: chains ?? [],
            createdAt: createdAt,
            expireAt: expireAt,
            metadata: WalletConnectionSessionAppMetadata(
                name: appName,
                description: appDescription,
                url: appLink,
                icon: appIcon,
                redirectNative: redirectNative,
                redirectUniversal: redirectUniversal
            )
        )
    }
    
    func update(with session: WalletConnectionSession) -> WalletConnectionRecord {
        return WalletConnectionRecord(
            id: session.id,
            sessionId: session.sessionId,
            walletId: walletId,
            state: session.state,
            chains: chains ?? [],
            createdAt: createdAt,
            expireAt: session.expireAt,
            appName: session.metadata.name,
            appDescription: session.metadata.description,
            appLink: session.metadata.url,
            appIcon: session.metadata.icon,
            redirectNative: session.metadata.redirectNative,
            redirectUniversal: session.metadata.redirectUniversal
        )
    }
}
