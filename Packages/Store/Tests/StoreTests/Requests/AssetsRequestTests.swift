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
        let db = DB.mockAssets()
        let balanceStore = BalanceStore(db: db)

        let assetId = AssetId(chain: .bitcoin, tokenId: nil)
        try balanceStore.pinAsset(walletId: .mock(), assetId: assetId, value: true)
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock().fetch(db)

            #expect(assets.first?.asset.id == assetId)
            #expect(assets.first?.metadata.isPinned == true)
            #expect(assets.first?.metadata.isBalanceEnabled == true)
        }
    }
    
    @Test func testEnabled() throws {
        let db = DB.mockAssets()
        let balanceStore = BalanceStore(db: db)
        
        let disabledId = AssetId(chain: .bitcoin)
        try balanceStore.setIsEnabled(walletId: .mock(), assetIds: [disabledId], value: false)
        
        try db.dbQueue.read { db in
            let enabledAssets = try AssetsRequest.mock(filters: [.enabledBalance]).fetch(db)
            let enabledIds = enabledAssets.map { $0.asset.id }

            #expect(enabledAssets.count == 4)
            #expect(enabledIds.contains(disabledId) == false)
        }
    }
    
    @Test func testAssetProperties() throws {
        let db = DB.mockAssets()
        let assetStore = AssetStore(db: db)
        
        let assetId = AssetId(chain: .bitcoin)
        try assetStore.setAssetIsBuyable(for: [assetId.identifier], value: false)
        try assetStore.setAssetIsStakeable(for: [assetId.identifier], value: false)
        try assetStore.setAssetIsSwappable(for: [assetId.identifier], value: false)
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock(filters: [.buyable, .stakeable, .swappable]).fetch(db)
            
            #expect(assets.count == 4)
            #expect(assets.map { $0.asset.id }.contains(assetId) == false)
        }
    }
    
    @Test func testHasBalance() throws {
        let db = DB.mockAssets()
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock(filters: [.hasBalance]).fetch(db)
            
            #expect(assets.count == 4)
            #expect(assets.first?.asset.id == AssetId(chain: .smartChain))
        }
    }
    
    @Test func testChains() throws {
        let db = DB.mockAssets()
        
        try db.dbQueue.read { db in
            let ethereumAssets = try AssetsRequest.mock(filters: [.chains([Chain.ethereum.rawValue, Chain.solana.rawValue])]).fetch(db)
            let bitcoinAssets = try AssetsRequest.mock(filters: [.chains([Chain.bitcoin.rawValue, Chain.base.rawValue])]).fetch(db)
            
            #expect(ethereumAssets.count == 2)
            #expect(bitcoinAssets.count == 1)
        }
    }
    
    @Test func testChainsOrAssets() throws {
        let db = DB.mockAssets()
        
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
        let db = DB.mockAssets()
        let searchStore = SearchStore(db: db)

        let query = "usdt ethereum"
        try searchStore.add(type: .asset, query: query, ids: [Asset.mockEthereumUSDT().id.identifier])
        try searchStore.add(type: .asset, query: "T", ids: [AssetBasic].mock().reversed().map { $0.asset.id.identifier })

        try db.dbQueue.read { db in
            let btc = try AssetsRequest.mock(filters: [.search("btc", hasPriorityAssets: false)]).fetch(db)
            let bnb = try AssetsRequest.mock(filters: [.search("bNb", hasPriorityAssets: false)]).fetch(db)
            let tron = try AssetsRequest.mock(filters: [.search("0xdAC17F958D2ee523a2206206994597C13D831ec7", hasPriorityAssets: false)]).fetch(db)
            let searchAssets = try AssetsRequest.mock(searchBy: query).fetch(db)
            let prioritySearchAssets = try AssetsRequest.mock(filters: [.search("T", hasPriorityAssets: true)]).fetch(db)

            #expect(btc.count == 1)
            #expect(btc.first?.asset.symbol == "BTC")
            #expect(bnb.count == 1)
            #expect(bnb.first?.asset.name == "BNB")
            #expect(tron.count == 1)
            #expect(tron.first?.asset.symbol == "USDT")
            #expect(searchAssets.count == 1)
            #expect(searchAssets.first?.asset.symbol == "USDT")
            #expect([AssetBasic].mock().reversed().map { $0.asset.id } == prioritySearchAssets.map { $0.asset.id })
        }
    }
    
    @Test func testOrder() throws {
        let db = DB.mockAssets()
        let priceStore = PriceStore(db: db)
        let fiatRateStore = FiatRateStore(db: db)
        let balanceStore = BalanceStore(db: db)
        
        try fiatRateStore.add([FiatRate(symbol: Currency.usd.rawValue, rate: 1)])
        
        try priceStore.updatePrice(
            price: AssetPrice(
                assetId: AssetId(chain: .tron),
                price: 100,
                priceChangePercentage24h: 100,
                updatedAt: .now
            ),
            currency: Currency.usd.rawValue
        )
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock().fetch(db)
            
            #expect(assets.first?.asset.id == AssetId(chain: .tron))
            #expect(assets.last?.asset.id == AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7"))
        }
        
        try balanceStore.pinAsset(walletId: .mock(), assetId: AssetId(chain: .bitcoin), value: true)
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock().fetch(db)
            
            #expect(assets.first?.asset.id == AssetId(chain: .bitcoin))
        }
    }
}

extension AssetsRequest {
    static func mock(
        walletId: WalletId = .mock(),
        searchBy: String = "",
        filters: [AssetsRequestFilter] = []
    ) -> AssetsRequest {
        AssetsRequest(walletId: walletId, searchBy: searchBy, filters: filters)
    }
}
