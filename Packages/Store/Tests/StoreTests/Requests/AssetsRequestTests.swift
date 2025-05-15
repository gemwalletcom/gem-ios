// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives

struct AssetsRequestTests {

    @Test func testAddAssets() throws {
        let db = DB.mock()
        let store = AssetStore(db: db)
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock().fetch(db)
            
            #expect(assets.isEmpty)
        }
        
        try store.add(assets: [.mock()])
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock(filters: [.priceAlerts]).fetch(db)
            
            #expect(assets.count == 1)
        }
    }
    
    @Test func testPinned() throws {
        let db = DB.mock()
        let balanceStore = BalanceStore(db: db)
        try prepareDatabase(db)
        
        let assetId = AssetId(chain: .bitcoin, tokenId: nil)
        try balanceStore.pinAsset(walletId: .empty, assetId: assetId.identifier, value: true)
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock().fetch(db)

            #expect(assets.first?.asset.id == assetId)
            #expect(assets.first?.metadata.isPinned == true)
            #expect(assets.first?.metadata.isEnabled == true)
        }
    }
    
    @Test func testEnabled() throws {
        let db = DB.mock()
        let balanceStore = BalanceStore(db: db)
        try prepareDatabase(db)
        
        let disabledId = AssetId(chain: .bitcoin)
        try balanceStore.setIsEnabled(walletId: .empty, assetIds: [disabledId.identifier], value: false)
        
        try db.dbQueue.read { db in
            let enabledAssets = try AssetsRequest.mock(filters: [.enabled]).fetch(db)
            let hiddenAssets = try AssetsRequest.mock(filters: [.hidden]).fetch(db)
            let enabledIds = enabledAssets.map { $0.asset.id }

            #expect(enabledAssets.count == 4)
            #expect(enabledIds.contains(disabledId) == false)
            
            #expect(hiddenAssets.count == 1)
            #expect(hiddenAssets.first?.asset.id == disabledId)
        }
    }
    
    @Test func testAssetProperties() throws {
        let db = DB.mock()
        let assetStore = AssetStore(db: db)
        try prepareDatabase(db)
        
        let assetId = AssetId(chain: .bitcoin, tokenId: "1")
        try assetStore.setAssetIsBuyable(for: [assetId.identifier], value: false)
        try assetStore.setAssetIsStakeable(for: [assetId.identifier], value: false)
        try assetStore.setAssetIsSwappable(for: [assetId.identifier], value: false)
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock(filters: [.buyable, .stakeable, .swappable]).fetch(db)
            
            #expect(assets.map { $0.asset.id }.contains(assetId) == false)
        }
    }
    
    @Test func testHasBalance() throws {
        let db = DB.mock()
        let balanceStore = BalanceStore(db: db)
        try prepareDatabase(db)
        
        let assetId = AssetId(chain: .bitcoin)
        try balanceStore.updateBalances(
            [UpdateBalance(
                assetID: assetId.identifier,
                type: .token(UpdateTokenBalance(available: UpdateBalanceValue(value: "1", amount: 1))),
                updatedAt: .now,
                isActive: true
            )],
            for: .empty
        )
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock(filters: [.hasBalance]).fetch(db)
            
            #expect(assets.count == 1)
            #expect(assets.first?.asset.id == assetId)
        }
    }
    
    @Test func testChains() throws {
        let db = DB.mock()
        try prepareDatabase(db)
        
        try db.dbQueue.read { db in
            let ethereumAssets = try AssetsRequest.mock(filters: [.chains([Chain.ethereum.rawValue, Chain.solana.rawValue])]).fetch(db)
            let bitcoinAssets = try AssetsRequest.mock(filters: [.chains([Chain.bitcoin.rawValue, Chain.base.rawValue])]).fetch(db)
            
            #expect(ethereumAssets.count == 2)
            #expect(bitcoinAssets.count == 1)
        }
    }
    
    @Test func testChainsOrAssets() throws {
        let db = DB.mock()
        try prepareDatabase(db)
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock(
                filters: [.chainsOrAssets([],
                    [
                        AssetId(chain: .bitcoin).identifier,
                        AssetId(chain: .smartChain).identifier
                    ]
                )]
            ).fetch(db)
            
            #expect(assets.count == 2)
        }
    }
    
    @Test func testSearch() throws {
        let db = DB.mock()
        let assetStore = AssetStore(db: db)
        try prepareDatabase(db)
        
        let query = "usdt ethereum"
        try assetStore.addAssetsSearch(query: query, assets: [.mock(asset: .mockEthereumUSDT())])
        
        try db.dbQueue.read { db in
            let btc = try AssetsRequest.mock(filters: [.search("btc", hasPriorityAssets: false)]).fetch(db)
            let bnb = try AssetsRequest.mock(filters: [.search("bNb", hasPriorityAssets: false)]).fetch(db)
            let tron = try AssetsRequest.mock(filters: [.search("0xdAC17F958D2ee523a2206206994597C13D831ec7", hasPriorityAssets: false)]).fetch(db)
            let searchAssets = try AssetsRequest.mock(searchBy: query).fetch(db)
            
            #expect(btc.count == 1)
            #expect(btc.first?.asset.symbol == "BTC")
            #expect(bnb.count == 1)
            #expect(bnb.first?.asset.name == "BNB")
            #expect(tron.count == 1)
            #expect(tron.first?.asset.symbol == "USDT")
            #expect(searchAssets.count == 1)
            #expect(searchAssets.first?.asset.symbol == "USDT")
        }
    }

    // MARK: - Private methods
    
    private func prepareDatabase(_ db: DB) throws {
        let assetStore = AssetStore(db: db)
        let balanceStore = BalanceStore(db: db)
        let walletStore = WalletStore(db: db)

        let mocks: [AssetBasic] = [
            .mock(asset: .mock()),
            .mock(asset: .mockBNB()),
            .mock(asset: .mockTron()),
            .mock(asset: .mockEthereum()),
            .mock(asset: .mockEthereumUSDT())
        ]
        try assetStore.add(assets: mocks)
        try walletStore.addWallet(.mock(accounts: mocks.map { Account.mock(chain: $0.asset.chain) }))
        try balanceStore.addBalance(mocks.map { AddBalance(assetId: $0.asset.id, isEnabled: true) }, for: .empty)
    }
}

extension AssetsRequest {
    static func mock(
        walletId: String = "",
        searchBy: String = "",
        filters: [AssetsRequestFilter] = []
    ) -> AssetsRequest {
        AssetsRequest(walletId: walletId, searchBy: searchBy, filters: filters)
    }
}
