// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import GRDB
import Primitives
import PrimitivesTestKit
import StoreTestKit
@testable import Store

private func setOrder(db: DB, walletId: String, order: Int) throws {
    try db.dbQueue.write { db in
        try db.execute(sql: "UPDATE wallets SET \"order\" = ? WHERE id = ?", arguments: [order, walletId])
    }
}

@Suite(.serialized)
struct WalletIdMigrationTests {

    private let currentWalletKey = "currentWallet"

    @Test
    func migrateMulticoinWallet() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let oldId = "uuid-multicoin-1"
        let ethAddress = "0x1234567890abcdef"
        let wallet = Wallet.mock(
            id: oldId,
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: ethAddress), .mock(chain: .bitcoin)]
        )
        try walletStore.addWallet(wallet)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == "multicoin_\(ethAddress)")
        #expect(wallets.first?.externalId == oldId)
    }

    @Test
    func migrateViewWallet() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let oldId = "uuid-view-1"
        let address = "0xviewaddress"
        let wallet = Wallet.mock(
            id: oldId,
            type: .view,
            accounts: [.mock(chain: .ethereum, address: address)]
        )
        try walletStore.addWallet(wallet)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == "view_ethereum_\(address)")
        #expect(wallets.first?.externalId == oldId)
    }

    @Test
    func migrateSingleWallet() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let oldId = "uuid-single-1"
        let address = "bc1qsingleaddress"
        let wallet = Wallet.mock(
            id: oldId,
            type: .single,
            accounts: [.mock(chain: .bitcoin, address: address)]
        )
        try walletStore.addWallet(wallet)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == "single_bitcoin_\(address)")
        #expect(wallets.first?.externalId == oldId)
    }

    @Test
    func migratePrivateKeyWallet() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let oldId = "uuid-pk-1"
        let address = "0xprivatekey"
        let wallet = Wallet.mock(
            id: oldId,
            type: .privateKey,
            accounts: [.mock(chain: .ethereum, address: address)]
        )
        try walletStore.addWallet(wallet)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == "privateKey_ethereum_\(address)")
        #expect(wallets.first?.externalId == oldId)
    }

    @Test
    func removeDuplicateMulticoinWallets() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let ethAddress = "0xsameaddress"

        let wallet1 = Wallet.mock(
            id: "uuid-1",
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: ethAddress)],
            order: 0
        )
        let wallet2 = Wallet.mock(
            id: "uuid-2",
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: ethAddress)],
            order: 1
        )
        let wallet3 = Wallet.mock(
            id: "uuid-3",
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: ethAddress)],
            order: 2
        )

        try walletStore.addWallet(wallet1)
        try walletStore.addWallet(wallet2)
        try walletStore.addWallet(wallet3)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == "multicoin_\(ethAddress)")
        #expect(wallets.first?.externalId == "uuid-1")
    }

    @Test
    func mixedWalletTypes() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let multicoin = Wallet.mock(
            id: "uuid-multicoin",
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: "0xmulti")],
            order: 0
        )
        let single = Wallet.mock(
            id: "uuid-single",
            type: .single,
            accounts: [.mock(chain: .bitcoin, address: "bc1single")],
            order: 1
        )
        let view = Wallet.mock(
            id: "uuid-view",
            type: .view,
            accounts: [.mock(chain: .solana, address: "solview")],
            order: 2
        )

        try walletStore.addWallet(multicoin)
        try walletStore.addWallet(single)
        try walletStore.addWallet(view)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 3)

        let ids = Set(wallets.map { $0.id })
        #expect(ids.contains("multicoin_0xmulti"))
        #expect(ids.contains("single_bitcoin_bc1single"))
        #expect(ids.contains("view_solana_solview"))
    }

    @Test
    func updateChildTableReferences() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)
        let balanceStore = BalanceStore(db: db)
        let assetStore = AssetStore(db: db)

        let oldId = "uuid-with-balances"
        let ethAddress = "0xwithbalances"
        let wallet = Wallet.mock(
            id: oldId,
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: ethAddress)]
        )
        try walletStore.addWallet(wallet)

        let asset = AssetBasic.mock(asset: .mock(id: .mockEthereum()))
        try assetStore.add(assets: [asset])
        try balanceStore.addBalance([AddBalance(assetId: asset.asset.id, isEnabled: true)], for: wallet.walletId)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let newWalletId = WalletId(id: "multicoin_\(ethAddress)")
        let balances = try balanceStore.getBalances(walletId: newWalletId, assetIds: [asset.asset.id])
        #expect(balances.count == 1)
    }

    @Test
    func multipleDuplicateGroups() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        // Group 1: 3 wallets with same eth address
        let address1 = "0xaddress1"
        try walletStore.addWallet(.mock(id: "uuid-1a", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address1)], order: 0))
        try walletStore.addWallet(.mock(id: "uuid-1b", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address1)], order: 1))
        try walletStore.addWallet(.mock(id: "uuid-1c", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address1)], order: 2))

        // Group 2: 2 wallets with different eth address
        let address2 = "0xaddress2"
        try walletStore.addWallet(.mock(id: "uuid-2a", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address2)], order: 3))
        try walletStore.addWallet(.mock(id: "uuid-2b", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address2)], order: 4))

        // Unique wallet
        let address3 = "0xaddress3"
        try walletStore.addWallet(.mock(id: "uuid-3", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address3)], order: 5))

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 3)

        let ids = Set(wallets.map { $0.id })
        #expect(ids.contains("multicoin_\(address1)"))
        #expect(ids.contains("multicoin_\(address2)"))
        #expect(ids.contains("multicoin_\(address3)"))

        // Verify correct wallet was kept (lowest order)
        let wallet1 = wallets.first { $0.id == "multicoin_\(address1)" }
        #expect(wallet1?.externalId == "uuid-1a")

        let wallet2 = wallets.first { $0.id == "multicoin_\(address2)" }
        #expect(wallet2?.externalId == "uuid-2a")
    }

    @Test
    func duplicateViewWallets() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let address = "0xviewaddr"
        try walletStore.addWallet(.mock(id: "uuid-view-1", type: .view, accounts: [.mock(chain: .ethereum, address: address)]))
        try walletStore.addWallet(.mock(id: "uuid-view-2", type: .view, accounts: [.mock(chain: .ethereum, address: address)]))
        try setOrder(db: db, walletId: "uuid-view-1", order: 1)
        try setOrder(db: db, walletId: "uuid-view-2", order: 0)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == "view_ethereum_\(address)")
        #expect(wallets.first?.externalId == "uuid-view-2") // lower order wins
    }

    @Test
    func duplicateSingleWallets() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let address = "bc1qsingle"
        try walletStore.addWallet(.mock(id: "uuid-single-1", type: .single, accounts: [.mock(chain: .bitcoin, address: address)]))
        try walletStore.addWallet(.mock(id: "uuid-single-2", type: .single, accounts: [.mock(chain: .bitcoin, address: address)]))
        try walletStore.addWallet(.mock(id: "uuid-single-3", type: .single, accounts: [.mock(chain: .bitcoin, address: address)]))
        try setOrder(db: db, walletId: "uuid-single-1", order: 2)
        try setOrder(db: db, walletId: "uuid-single-2", order: 0)
        try setOrder(db: db, walletId: "uuid-single-3", order: 1)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == "single_bitcoin_\(address)")
        #expect(wallets.first?.externalId == "uuid-single-2") // order 0 wins
    }

    @Test
    func keepWalletWithLowestOrder() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let address = "0xordertest"
        try walletStore.addWallet(.mock(id: "uuid-order-5", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address)]))
        try walletStore.addWallet(.mock(id: "uuid-order-2", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address)]))
        try walletStore.addWallet(.mock(id: "uuid-order-8", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address)]))
        try walletStore.addWallet(.mock(id: "uuid-order-1", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address)]))
        try walletStore.addWallet(.mock(id: "uuid-order-3", type: .multicoin, accounts: [.mock(chain: .ethereum, address: address)]))
        try setOrder(db: db, walletId: "uuid-order-5", order: 5)
        try setOrder(db: db, walletId: "uuid-order-2", order: 2)
        try setOrder(db: db, walletId: "uuid-order-8", order: 8)
        try setOrder(db: db, walletId: "uuid-order-1", order: 1)
        try setOrder(db: db, walletId: "uuid-order-3", order: 3)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.externalId == "uuid-order-1") // lowest order wins
    }

    @Test
    func accountsUpdatedAfterMigration() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let oldId = "uuid-accounts"
        let ethAddress = "0xaccounts"
        let btcAddress = "bc1accounts"
        let wallet = Wallet.mock(
            id: oldId,
            type: .multicoin,
            accounts: [
                .mock(chain: .ethereum, address: ethAddress),
                .mock(chain: .bitcoin, address: btcAddress)
            ]
        )
        try walletStore.addWallet(wallet)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.accounts.count == 2)

        let chains = Set(wallets.first?.accounts.map { $0.chain } ?? [])
        #expect(chains.contains(.ethereum))
        #expect(chains.contains(.bitcoin))
    }

    @Test
    func walletAlreadyInNewFormat() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        // Wallet already has new format ID (simulating re-running migration)
        let ethAddress = "0xalreadymigrated"
        let newFormatId = "multicoin_\(ethAddress)"
        let wallet = Wallet.mock(
            id: newFormatId,
            externalId: "old-uuid",
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: ethAddress)]
        )
        try walletStore.addWallet(wallet)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let wallets = try walletStore.getWallets()
        #expect(wallets.count == 1)
        #expect(wallets.first?.id == newFormatId)
        #expect(wallets.first?.externalId == "old-uuid") // preserved
    }

    @Test
    func emptyDatabase() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)
        let db = DB.mock()

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let walletStore = WalletStore(db: db)
        let wallets = try walletStore.getWallets()
        #expect(wallets.isEmpty)
    }
}

@Suite(.serialized)
struct WalletIdMigrationPreferenceTests {

    private let currentWalletKey = "currentWallet"

    @Test
    func migrateCurrentWalletPreference() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)

        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        let oldId = "uuid-current"
        let ethAddress = "0xcurrent"
        let wallet = Wallet.mock(
            id: oldId,
            type: .multicoin,
            accounts: [.mock(chain: .ethereum, address: ethAddress)]
        )
        try walletStore.addWallet(wallet)

        UserDefaults.standard.set(oldId, forKey: currentWalletKey)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let newCurrentWalletId = UserDefaults.standard.string(forKey: currentWalletKey)
        #expect(newCurrentWalletId == "multicoin_\(ethAddress)")

        UserDefaults.standard.removeObject(forKey: currentWalletKey)
    }

    @Test
    func setCurrentWalletWhenNoneSet() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)

        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        try walletStore.addWallet(.mock(id: "uuid-first", type: .multicoin, accounts: [.mock(chain: .ethereum, address: "0xfirst")]))
        try setOrder(db: db, walletId: "uuid-first", order: 0)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let currentWalletId = UserDefaults.standard.string(forKey: currentWalletKey)
        #expect(currentWalletId == "multicoin_0xfirst")

        UserDefaults.standard.removeObject(forKey: currentWalletKey)
    }

    @Test
    func fallbackCurrentWalletWhenInvalid() throws {
        UserDefaults.standard.removeObject(forKey: currentWalletKey)

        let db = DB.mock()
        let walletStore = WalletStore(db: db)

        UserDefaults.standard.set("deleted-wallet-id", forKey: currentWalletKey)

        try walletStore.addWallet(.mock(id: "uuid-fallback", type: .multicoin, accounts: [.mock(chain: .ethereum, address: "0xfallback")]))
        try setOrder(db: db, walletId: "uuid-fallback", order: 0)

        try db.dbQueue.write { db in
            try WalletIdMigration.migrate(db: db)
        }

        let currentWalletId = UserDefaults.standard.string(forKey: currentWalletKey)
        #expect(currentWalletId == "multicoin_0xfallback")

        UserDefaults.standard.removeObject(forKey: currentWalletKey)
    }
}
