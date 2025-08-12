// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives
import GRDB

struct TransactionStoreTests {
    
    @Test func assetAssociationsReplacedOnUpdate() throws {
        let db = DB.mock()
        let store = TransactionStore(db: db)
        let walletId = "test-wallet"
        
        let btc = AssetId(chain: .bitcoin, tokenId: nil)
        let eth = AssetId(chain: .ethereum, tokenId: nil)
        let sol = AssetId(chain: .solana, tokenId: nil)
        
        // Add swap transaction with BTC->ETH
        let swap1 = Transaction(
            id: "tx1", hash: "h1", assetId: btc, from: "f", to: "t", contract: nil,
            type: .swap, state: .confirmed, blockNumber: "1", sequence: "1",
            fee: "1", feeAssetId: btc, value: "100", memo: nil, direction: .outgoing,
            utxoInputs: [], utxoOutputs: [],
            metadata: .swap(TransactionSwapMetadata(
                fromAsset: btc, fromValue: "100", toAsset: eth, toValue: "200", provider: nil
            )),
            createdAt: Date()
        )
        try store.addTransactions(walletId: walletId, transactions: [swap1])
        
        // Verify BTC and ETH associations exist
        let recordId = try db.dbQueue.read { db in
            try TransactionRecord.fetchAll(db).first { $0.transactionId == "tx1" }?.id
        }
        #expect(recordId != nil)
        
        var associations = try db.dbQueue.read { db in
            try TransactionAssetAssociationRecord
                .filter(Column("transactionId") == recordId!)
                .fetchAll(db)
                .map(\.assetId)
        }
        #expect(associations.count == 2)
        #expect(associations.contains(btc))
        #expect(associations.contains(eth))
        
        // Update to BTC->SOL swap
        let swap2 = Transaction(
            id: "tx1", hash: "h1", assetId: btc, from: "f", to: "t", contract: nil,
            type: .swap, state: .confirmed, blockNumber: "1", sequence: "1",
            fee: "1", feeAssetId: btc, value: "100", memo: nil, direction: .outgoing,
            utxoInputs: [], utxoOutputs: [],
            metadata: .swap(TransactionSwapMetadata(
                fromAsset: btc, fromValue: "100", toAsset: sol, toValue: "300", provider: nil
            )),
            createdAt: Date()
        )
        try store.addTransactions(walletId: walletId, transactions: [swap2])
        
        // Verify ETH replaced with SOL
        associations = try db.dbQueue.read { db in
            try TransactionAssetAssociationRecord
                .filter(Column("transactionId") == recordId!)
                .fetchAll(db)
                .map(\.assetId)
        }
        #expect(associations.count == 2)
        #expect(associations.contains(btc))
        #expect(associations.contains(sol))
        #expect(!associations.contains(eth))
    }
}