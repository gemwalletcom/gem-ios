// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct NodeSelectedRecordInfo: FetchableRecord, Codable {
    var node: NodeRecord
    var nodeSelected: NodeSelectedRecord
}

public struct NodeSelectedRecord: Codable, FetchableRecord, PersistableRecord, TableRecord  {
    public static let databaseTableName: String = "nodes_selected_v1"
    
    public enum Columns {
        static let nodeId = Column("nodeId")
        static let chain = Column("chain")
        static let auto = Column("auto")
    }

    public var nodeId: Int
    public var chain: Chain
    public var auto: Bool
    
    static let node = belongsTo(NodeRecord.self, key: "node")
}

extension NodeSelectedRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.nodeId.name, .text)
                .notNull()
                .indexed()
                .references(NodeRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.chain.name, .text)
                .primaryKey()
            $0.column(Columns.auto.name, .boolean)
        }
    }
}

extension NodeSelectedRecordInfo {
    func mapToChainNode() -> ChainNode {
        return node.mapToChainNode()
    }
}
