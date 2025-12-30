// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct NodeSelectedRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    public static let databaseTableName: String = "nodes_selected_v1"

    public enum Columns {
        static let chain = Column("chain")
        static let nodeUrl = Column("nodeUrl")
    }

    public var chain: Chain
    public var nodeUrl: String

}

extension NodeSelectedRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.chain.name, .text).primaryKey()
            $0.column(Columns.nodeUrl.name, .text).notNull()
        }
    }
}
