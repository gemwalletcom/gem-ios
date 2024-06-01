// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct NodeStore {
    
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
        return try nodeRecords(chain: chain)
            .map { $0.mapToChainNode() }
    }

    public func nodeRecord(chain: Chain, url: String) throws -> NodeRecord? {
        try db.read { db in
            try NodeRecord
                .filter(Columns.Node.chain == chain.rawValue)
                .filter(Columns.Node.url == url)
                .fetchOne(db)
        }
    }
    
    public func nodeRecords(chain: Chain) throws -> [NodeRecord] {
        try db.read { db in
            try NodeRecord
                .filter(Columns.Node.chain == chain.rawValue)
                .fetchAll(db)
        }
    }
    
    public func setNodeSelected(node: NodeRecord) throws {
        try db.write { (db: Database) in
            guard let nodeId = node.id else {
                throw AnyError("no node id")
            }
            try NodeSelectedRecord(nodeId: nodeId, chain: node.chain, auto: true)
                .upsert(db)
        }
    }
    
    public func deleteNodeSelected(chain: String) throws {
        return try db.write { (db: Database) in
            try NodeSelectedRecord
                .filter(Columns.Node.chain == chain)
                .deleteAll(db)
        }
    }
    
    public func selectedNodes() throws -> [ChainNode] {
        try db.read { db in
            try NodeSelectedRecord
                .including(required: NodeSelectedRecord.node)
                .asRequest(of: NodeSelectedRecordInfo.self)
                .fetchAll(db)
                .map { $0.mapToChainNode() }
        }
    }
    
    public func selectedNode(chain: String) throws -> ChainNode? {
        try db.read { db in
            try NodeSelectedRecord
                .including(required: NodeSelectedRecord.node)
                .filter(Columns.Node.chain == chain)
                .asRequest(of: NodeSelectedRecordInfo.self)
                .fetchOne(db)
                .map { $0.mapToChainNode() }
        }
    }
    
    public func allNodes() throws -> [Node] {
        try db.read { db in
            try NodeRecord
                .fetchAll(db)
                .map { $0.mapToNode() }
        }
    }
}
