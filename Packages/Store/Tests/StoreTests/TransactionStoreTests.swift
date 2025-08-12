// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives
import GRDB

struct TransactionStoreTests {
    
    @Test func swapAssociationsReplacedOnUpdate() throws {
        let db = DB.mock()
        let store = TransactionStore(db: db)
        let walletId = "test-wallet"
        
        // Create initial swap transaction with two asset associations
        let assetId1 = AssetId(chain: .bitcoin, tokenId: nil)
        let assetId2 = AssetId(chain: .ethereum, tokenId: nil)
        let swapMetadata = TransactionSwapMetadata(
            fromAsset: assetId1,
            fromValue: "100",
            toAsset: assetId2,
            toValue: "200",
            provider: nil
        )
        let transaction = Transaction(
            id: "tx1",
            hash: "hash1",
            assetId: assetId1,
            from: "from1",
            to: "to1",
            contract: nil,
            type: .swap,
            state: .confirmed,
            blockNumber: "1",
            sequence: "1",
            fee: "10",
            feeAssetId: assetId1,
            value: "100",
            memo: nil,
            direction: .outgoing,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: .swap(swapMetadata),
            createdAt: Date()
        )
        
        // Add initial transaction
        try store.addTransactions(walletId: walletId, transactions: [transaction])
        
        // Verify both associations exist
        try db.dbQueue.read { db in
            let records = try TransactionRecord.fetchAll(db)
            let record = records.first { $0.transactionId == "tx1" }
            
            #expect(record != nil)
            
            if let recordId = record?.id {
                let associations = try TransactionAssetAssociationRecord
                    .filter(Column("transactionId") == recordId)
                    .fetchAll(db)
                
                #expect(associations.count == 2)
                #expect(associations.contains { $0.assetId == assetId1 })
                #expect(associations.contains { $0.assetId == assetId2 })
            }
        }
        
        // Update swap transaction with different assets
        let assetId3 = AssetId(chain: .solana, tokenId: nil)
        let updatedSwapMetadata = TransactionSwapMetadata(
            fromAsset: assetId1,
            fromValue: "100",
            toAsset: assetId3,
            toValue: "300",
            provider: nil
        )
        let updatedTransaction = Transaction(
            id: "tx1",
            hash: "hash1",
            assetId: assetId1,
            from: "from1",
            to: "to1",
            contract: nil,
            type: .swap,
            state: .confirmed,
            blockNumber: "1",
            sequence: "1",
            fee: "10",
            feeAssetId: assetId1,
            value: "100",
            memo: nil,
            direction: .outgoing,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: .swap(updatedSwapMetadata),
            createdAt: Date()
        )
        
        // Update transaction
        try store.addTransactions(walletId: walletId, transactions: [updatedTransaction])
        
        // Verify associations were replaced
        try db.dbQueue.read { db in
            let records = try TransactionRecord.fetchAll(db)
            let record = records.first { $0.transactionId == "tx1" }
            
            #expect(record != nil)
            
            if let recordId = record?.id {
                let associations = try TransactionAssetAssociationRecord
                    .filter(Column("transactionId") == recordId)
                    .fetchAll(db)
                
                #expect(associations.count == 2)
                #expect(associations.contains { $0.assetId == assetId1 })
                #expect(associations.contains { $0.assetId == assetId3 })
                #expect(!associations.contains { $0.assetId == assetId2 })
            }
        }
    }
    
    @Test func transferAssociationsReplaced() throws {
        let db = DB.mock()
        let store = TransactionStore(db: db)
        let walletId = "test-wallet"
        
        // Create regular transfer transaction (only one asset)
        let assetId1 = AssetId(chain: .bitcoin, tokenId: nil)
        let transaction = Transaction(
            id: "tx2",
            hash: "hash2",
            assetId: assetId1,
            from: "from2",
            to: "to2",
            contract: nil,
            type: .transfer,
            state: .confirmed,
            blockNumber: "2",
            sequence: "2",
            fee: "10",
            feeAssetId: assetId1,
            value: "100",
            memo: nil,
            direction: .incoming,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: nil,
            createdAt: Date()
        )
        
        // Add transaction
        try store.addTransactions(walletId: walletId, transactions: [transaction])
        
        // Verify association exists
        try db.dbQueue.read { db in
            let records = try TransactionRecord.fetchAll(db)
            let record = records.first { $0.transactionId == "tx2" }
            
            #expect(record != nil)
            
            if let recordId = record?.id {
                let associations = try TransactionAssetAssociationRecord
                    .filter(Column("transactionId") == recordId)
                    .fetchAll(db)
                
                #expect(associations.count == 1)
                #expect(associations.first?.assetId == assetId1)
            }
        }
        
        // Update to different asset
        let assetId2 = AssetId(chain: .ethereum, tokenId: nil)
        let updatedTransaction = Transaction(
            id: "tx2",
            hash: "hash2",
            assetId: assetId2,
            from: "from2",
            to: "to2",
            contract: nil,
            type: .transfer,
            state: .confirmed,
            blockNumber: "2",
            sequence: "2",
            fee: "10",
            feeAssetId: assetId2,
            value: "100",
            memo: nil,
            direction: .incoming,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: nil,
            createdAt: Date()
        )
        
        // Update transaction
        try store.addTransactions(walletId: walletId, transactions: [updatedTransaction])
        
        // Verify association was replaced
        try db.dbQueue.read { db in
            let records = try TransactionRecord.fetchAll(db)
            let record = records.first { $0.transactionId == "tx2" }
            
            #expect(record != nil)
            
            if let recordId = record?.id {
                let associations = try TransactionAssetAssociationRecord
                    .filter(Column("transactionId") == recordId)
                    .fetchAll(db)
                
                #expect(associations.count == 1)
                #expect(associations.first?.assetId == assetId2)
            }
        }
    }
}