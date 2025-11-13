// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import WalletsServiceTestKit
import StoreTestKit
import BalanceServiceTestKit
import PrimitivesTestKit
import Primitives
import GRDB

@testable import Store
@testable import WalletsService

struct WalletsServiceTests {
    @Test
    func setupMulticoinWallet() throws {
        let (db, balanceStore, walletStore, service) = setupService()
        let wallet = Wallet.mock(id: "test", type: .multicoin, accounts: [.mock(chain: .cosmos), .mock(chain: .ethereum)])

        try addAsset(db: db, chain: .cosmos)
        try addAsset(db: db, chain: .ethereum)
        try walletStore.addWallet(wallet)
        try service.setup(wallet: wallet)

        let isEnabled = try balanceStore.getBalanceRecord(walletId: wallet.walletId.id, assetId: AssetId(chain: .cosmos).identifier)?.isEnabled

        #expect(isEnabled == false)
    }

    @Test
    func setupSingleWallet() throws {
        let (db, balanceStore, walletStore, service) = setupService()
        let wallet = Wallet.mock(id: "test", type: .single, accounts: [.mock(chain: .cosmos)])

        try addAsset(db: db, chain: .cosmos)
        try walletStore.addWallet(wallet)
        try service.setup(wallet: wallet)

        let isEnabled = try balanceStore.getBalanceRecord(walletId: wallet.walletId.id, assetId: AssetId(chain: .cosmos).identifier)?.isEnabled

        #expect(isEnabled == true)
    }

    private func setupService() -> (DB, BalanceStore, WalletStore, WalletsService) {
        let db = DB.mock()
        let balanceStore = BalanceStore.mock(db: db)
        let walletStore = WalletStore.mock(db: db)
        let service = WalletsService.mock(walletStore: walletStore, balanceService: .mock(balanceStore: balanceStore))
        return (db, balanceStore, walletStore, service)
    }

    private func addAsset(db: DB, chain: Chain) throws {
        try db.dbQueue.write { db in
            try Asset.mock(id: AssetId(chain: chain)).record.insert(db)
        }
    }
}
