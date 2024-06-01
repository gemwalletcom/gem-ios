// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ConnectionsStore {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addConnection(_ connection: WalletConnection) throws {
        try db.write { db in
            try connection.record.insert(db)
        }
    }
    
    public func getConnection(id: String) throws -> WalletConnection {
        try db.read { db in
            let result = try WalletRecord
                .including(required: WalletRecord.connection)
                .asRequest(of: WalletConnectionInfo.self)
                .filter(
                    SQL(stringLiteral: String(format: "%@.sessionId == '%@'", WalletConnectionRecord.databaseTableName, id))
                )
                .fetchOne(db)
            guard let connection = result else {
                throw AnyError("")
            }
            return connection.mapToWalletConnection()
        }
    }
    
    public func getConnectionRecord(id: String) throws -> WalletConnectionRecord {
        try db.read { db in
            guard let connection = try WalletConnectionRecord
                .filter(Column("id") == id || Column("sessionId") == id)
                .fetchOne(db) else {
                throw AnyError("wallet connection record not found")
            }
            return connection
        }
    }
    
    public func getSessions() throws -> [WalletConnectionSession] {
        try db.read { db in
            try WalletConnectionRecord
                .fetchAll(db)
                .map { $0.session }
        }
    }
    
    public func updateConnectionSession(_ session: WalletConnectionSession) throws {
        let connection = try getConnectionRecord(id: session.id).update(with: session)
        try db.write { db in
            try connection.upsert(db)
        }
    }
    
    public func delete(ids: [String]) throws {
        return try db.write { db in
            try WalletConnectionRecord
                .filter(ids.contains(Columns.Connection.id) || ids.contains(Columns.Connection.sessionId) )
                .deleteAll(db)
        }
    }
    
    public func deleteAll() throws {
        return try db.write { db in
            try WalletConnectionRecord.deleteAll(db)
        }
    }
}
