// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct NodeStore: Sendable {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addNodes(chainNodes: [ChainNodes]) throws {
        try db.write { (db: Database) in
            for chainNode in chainNodes {
                for node in chainNode.nodes {
                    if let chain = Chain(rawValue: chainNode.chain) {
                        try node
                            .mapToRecord(chain: chain)
                            .insert(db, onConflict: .ignore)
                    }
                }
            }
        }
    }
    
    public func nodes(chain: Chain) throws -> [ChainNode] {
        try db.read { db in
            try NodeRecord
                .filter(NodeRecord.Columns.chain == chain.rawValue)
                .fetchAll(db)
                .map { $0.mapToChainNode() }
        }
    }
    
    public func setNodeSelected(chain: Chain, url: String) throws {
        try db.write { (db: Database) in
            try NodeSelectedRecord(chain: chain, nodeUrl: url).upsert(db)
        }
    }

    public func deleteNode(chain: Chain, url: String) throws {
        _ = try db.write { db in
            try NodeRecord
                .filter(NodeRecord.Columns.chain == chain.rawValue && NodeRecord.Columns.url == url)
                .deleteAll(db)
        }
    }

    public func selectedNodeUrl(chain: Chain) throws -> String? {
        try db.read { db in
            try NodeSelectedRecord
                .filter(NodeSelectedRecord.Columns.chain == chain.rawValue)
                .fetchOne(db)?
                .nodeUrl
        }
    }
    
    public func deleteNodeSelected(chain: Chain) throws {
        _ = try db.write { (db: Database) in
            try NodeSelectedRecord
                .filter(NodeRecord.Columns.chain == chain.rawValue)
                .deleteAll(db)
        }
    }
}
