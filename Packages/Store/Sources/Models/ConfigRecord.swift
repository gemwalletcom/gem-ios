// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct ConfigRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "config"

    public enum Columns {
        static let id = Column("id")
        static let config = Column("config")
        static let updatedAt = Column("updatedAt")
    }

    public var id: String
    public var config: ConfigResponse
    public var updatedAt: Date
}

extension ConfigRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text).notNull()
            $0.column(Columns.config.name, .jsonText).notNull()
            $0.column(Columns.updatedAt.name, .date).notNull()
        }
    }
}

extension ConfigResponse {
    var record: ConfigRecord {
        ConfigRecord(id: "default", config: self, updatedAt: .now)
    }
}
