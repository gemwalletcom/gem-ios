// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ConnectionsStore: Sendable {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    // MARK: - Public methods
    
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
                    TableAlias(name: WalletConnectionRecord.databaseTableName)[Columns.Connection.sessionId] == id
                )
                .fetchOne(db)
            guard let connection = result else {
                throw AnyError("Wallet connection not found")
            }
            return connection.mapToWalletConnection()
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
        let connection = try getConnection(id: session.id).update(with: session)
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
    
    // MARK: - Private methods
    
    private func getConnection(id: String) throws -> WalletConnectionRecord {
        try db.read { db in
            guard let connection = try WalletConnectionRecord
                .filter(Columns.Connection.id == id || Columns.Connection.sessionId == id)
                .fetchOne(db)
            else {
                throw AnyError("wallet connection record not found")
            }
            return connection
        }
    }
}
