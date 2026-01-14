// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct SearchRecord: Codable, PersistableRecord, FetchableRecord, TableRecord, Sendable {
    public static let databaseTableName = "search"

    public enum Columns {
        static let query = Column("query")
        static let assetId = Column("assetId")
        static let perpetualId = Column("perpetualId")
        static let priority = Column("priority")
    }

    public var query: String
    public var assetId: String?
    public var perpetualId: String?
    public var priority: Int

    public init(query: String, assetId: String? = nil, perpetualId: String? = nil, priority: Int) {
        self.query = query
        self.assetId = assetId
        self.perpetualId = perpetualId
        self.priority = priority
    }
}

extension SearchRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: databaseTableName, ifNotExists: true) {
            $0.column(Columns.query.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.assetId.name, .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.perpetualId.name, .text)
                .references(PerpetualRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.priority.name, .integer)
                .notNull()
            $0.uniqueKey([Columns.query.name, Columns.assetId.name])
            $0.uniqueKey([Columns.query.name, Columns.perpetualId.name])
        }
    }
}
