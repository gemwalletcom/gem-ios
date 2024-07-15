// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct NodeRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static var databaseTableName: String = "nodes"

    public var id: Int?
    public var url: String
    public var chain: Chain
    public var status: String
    public var priority: Int
}

extension NodeRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("url", .text)
                .unique()
            t.column("chain", .text)
                .notNull()
                .indexed()
            t.column("status", .text)
            t.column("priority", .integer)
        }
    }
}

extension NodeRecord {
    func mapToChainNode() -> ChainNode {
        return ChainNode(
            chain: chain.rawValue,
            node: mapToNode()
        )
    }
    
    func mapToNode() -> Node {
        return Node(
            url: url,
            status: NodeState(rawValue: status) ?? .inactive,
            priority: priority.asInt32
        )
    }
}

extension Node {
    func mapToRecord(chain: Chain) -> NodeRecord {
        return NodeRecord(
            url: url,
            chain: chain,
            status: status.rawValue,
            priority: Int(priority)
        )
    }
}
