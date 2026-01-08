// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import PrimitivesTestKit

public extension DB {
    static func mock() -> DB {
        DB(fileName: "\(UUID().uuidString).sqlite")
    }
    
    static func mockAssets(assets: [AssetBasic] = .mock()) -> DB {
        let db = Self.mock()
        let assetStore = AssetStore(db: db)
        let balanceStore = BalanceStore(db: db)
        let walletStore = WalletStore(db: db)

        try? assetStore.add(assets: assets)
        try? walletStore.addWallet(.mock(accounts: assets.map { Account.mock(chain: $0.asset.chain) }))
        try? balanceStore.addBalance(assets.map { AddBalance(assetId: $0.asset.id, isEnabled: true) }, for: .mock())
        try? balanceStore.updateBalances(.mock(assets: assets), for: .mock())
        
        return db
    }
}
