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
        
        let btc = AssetId(chain: .bitcoin, tokenId: nil)
        let eth = AssetId(chain: .ethereum, tokenId: nil)
        let sol = AssetId(chain: .solana, tokenId: nil)
        
        // Add swap BTC->ETH
        try store.addTransactions(walletId: "w1", transactions: [
            .mock(
                id: "tx1",
                type: .swap,
                assetId: btc,
                metadata: .swap(TransactionSwapMetadata(
                    fromAsset: btc, fromValue: "100", toAsset: eth, toValue: "200", provider: nil
                ))
            )
        ])
        
        // Update to BTC->SOL
        try store.addTransactions(walletId: "w1", transactions: [
            .mock(
                id: "tx1",
                type: .swap,
                assetId: btc,
                metadata: .swap(TransactionSwapMetadata(
                    fromAsset: btc, fromValue: "100", toAsset: sol, toValue: "300", provider: nil
                ))
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