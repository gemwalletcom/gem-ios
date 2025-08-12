// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives
import GRDB

struct TransactionStoreTests {
    
    @Test func assetAssociationsReplaced() throws {
        let db = DB.mock()
        let store = TransactionStore(db: db)
        
        // Add swap BTC->ETH
        let btc = AssetId(chain: .bitcoin, tokenId: nil)
        let eth = AssetId(chain: .ethereum, tokenId: nil)
        let sol = AssetId(chain: .solana, tokenId: nil)
        
        try store.addTransactions(walletId: "w1", transactions: [
            Transaction(
                id: "tx1", hash: "h1", assetId: btc, from: "f", to: "t", contract: nil,
                type: .swap, state: .confirmed, blockNumber: "1", sequence: "1",
                fee: "1", feeAssetId: btc, value: "100", memo: nil, direction: .outgoing,
                utxoInputs: [], utxoOutputs: [],
                metadata: .swap(TransactionSwapMetadata(
                    fromAsset: btc, fromValue: "100", toAsset: eth, toValue: "200", provider: nil
                )),
                createdAt: Date()
            )
        ])
        
        // Update to BTC->SOL
        try store.addTransactions(walletId: "w1", transactions: [
            Transaction(
                id: "tx1", hash: "h1", assetId: btc, from: "f", to: "t", contract: nil,
                type: .swap, state: .confirmed, blockNumber: "1", sequence: "1",
                fee: "1", feeAssetId: btc, value: "100", memo: nil, direction: .outgoing,
                utxoInputs: [], utxoOutputs: [],
                metadata: .swap(TransactionSwapMetadata(
                    fromAsset: btc, fromValue: "100", toAsset: sol, toValue: "300", provider: nil
                )),
                createdAt: Date()
            )
        ])
        
        // Verify old associations replaced
        try db.dbQueue.read { db in
            let recordId = try TransactionRecord.fetchAll(db).first?.id
            let assetIds = try TransactionAssetAssociationRecord
                .filter(Column("transactionId") == recordId!)
                .fetchAll(db)
                .map(\.assetId)
            
            #expect(assetIds == [btc, sol])
        }
    }
}