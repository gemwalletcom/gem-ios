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
        let btc = AssetId(chain: .bitcoin, tokenId: nil)
        let eth = AssetId(chain: .ethereum, tokenId: nil)
        let sol = AssetId(chain: .solana, tokenId: nil)
        
        let assets: [AssetBasic] = [
            .mock(asset: .mock(id: btc)),
            .mock(asset: .mock(id: eth)),
            .mock(asset: .mock(id: sol))
        ]
        
        let db = DB.mockAssets(assets: assets)
        let walletStore = WalletStore(db: db)
        try walletStore.addWallet(.mock(id: "1", accounts: assets.map { Account.mock(chain: $0.asset.chain) }))
        
        let store = TransactionStore(db: db)
        let transactionId = "1"

        try store.addTransactions(walletId: "1", transactions: [
            .mock(
                id: transactionId,
                type: .swap,
                assetId: btc,
                metadata: .swap(TransactionSwapMetadata(
                    fromAsset: btc, fromValue: "100", toAsset: eth, toValue: "200", provider: nil, swapResult: nil
                ))
            )
        ])
        
        try store.addTransactions(walletId: "1", transactions: [
            .mock(
                id: transactionId,
                type: .swap,
                assetId: btc,
                metadata: .swap(TransactionSwapMetadata(
                    fromAsset: btc, fromValue: "100", toAsset: sol, toValue: "300", provider: nil, swapResult: nil
                ))
            )
        ])
        
        let assetIds = try store.getTransactionAssetAssociations(for: transactionId).map(\.assetId)
        
        #expect(assetIds == [btc, sol])
    }
}
