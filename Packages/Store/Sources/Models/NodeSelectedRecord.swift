// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct NodeSelectedRecordInfo: FetchableRecord, Codable {
    var node: NodeRecord
    var nodeSelected: NodeSelectedRecord
}

public struct NodeSelectedRecord: Codable, FetchableRecord, PersistableRecord, TableRecord  {
    
    public static var databaseTableName: String = "nodes_selected_v1"

    public var nodeId: Int
    public var chain: Chain
    public var auto: Bool
    
    static let node = belongsTo(NodeRecord.self, key: "node")
}

extension NodeSelectedRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("nodeId", .text)
                .notNull()
                .indexed()
                .references(NodeRecord.databaseTableName, onDelete: .cascade)
            $0.column("chain", .text)
                .primaryKey()
            $0.column("auto", .boolean)
        }
    }
}

extension NodeSelectedRecordInfo {
    func mapToChainNode() -> ChainNode {
        return node.mapToChainNode()
    }
}


//extension Node {
//    func mapToSelectedRecord(chain: String) -> NodeSelectedRecord {
//        return NodeSelectedRecord(
//            chain: chain,
//            url: url,
//            auto: true
//        )
//    }
//}

//
//extension NodeSelectedRecord {
//    func mapToNode() -> Node {
//        return Node(
//            url: url,
//            status: NodeStatus(rawValue: status) ?? .inactive,
//            priority: Int32(priority)
//        )
//    }
//}
