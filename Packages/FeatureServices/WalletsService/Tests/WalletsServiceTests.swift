// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import StoreTestKit
import BalanceServiceTestKit
import PrimitivesTestKit
import Primitives
import WalletSessionService
import PreferencesTestKit
import GRDB

@testable import Store
@testable import WalletsService

struct WalletSetupServiceTests {
    @Test
    func setupMulticoinWallet() throws {
        let (db, balanceStore, walletStore, service) = setupService()
        let wallet = Wallet.mock(id: "test", type: .multicoin, accounts: [.mock(chain: .cosmos), .mock(chain: .ethereum)])

        try addAsset(db: db, chain: .cosmos)
        try addAsset(db: db, chain: .ethereum)
        try walletStore.addWallet(wallet)
        try service.setup(wallet: wallet)

        let isEnabled = try balanceStore.getBalanceRecord(walletId: wallet.walletId, assetId: AssetId(chain: .cosmos))?.isEnabled

        #expect(isEnabled == false)
    }

    @Test
    func setupSingleWallet() throws {
        let (db, balanceStore, walletStore, service) = setupService()
        let wallet = Wallet.mock(id: "test", type: .single, accounts: [.mock(chain: .cosmos)])

        try addAsset(db: db, chain: .cosmos)
        try walletStore.addWallet(wallet)
        try service.setup(wallet: wallet)

        let isEnabled = try balanceStore.getBalanceRecord(walletId: wallet.walletId, assetId: AssetId(chain: .cosmos))?.isEnabled

        #expect(isEnabled == true)
    }

    private func setupService() -> (DB, BalanceStore, WalletStore, WalletSetupService) {
        let db = DB.mock()
        let balanceStore = BalanceStore.mock(db: db)
        let walletStore = WalletStore.mock(db: db)
        let walletSessionService = WalletSessionService(walletStore: walletStore, preferences: .mock())
        let balanceUpdater = BalanceUpdateService(
            balanceService: .mock(balanceStore: balanceStore),
            walletSessionService: walletSessionService
        )
        let service = WalletSetupService(balanceUpdater: balanceUpdater)
        return (db, balanceStore, walletStore, service)
    }

    private func addAsset(db: DB, chain: Chain) throws {
        try db.dbQueue.write { db in
            try Asset.mock(id: AssetId(chain: chain)).record.insert(db)
        }
    }
}
