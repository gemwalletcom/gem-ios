// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import DeviceService

struct SubscriptionServiceTests {
    @Test
    func addNewChainToExisting() {
        let local = [
            WalletSubscription(
                walletId: "wallet1",
                source: .import,
                subscriptions: [
                    AddressChains(address: "btc1", chains: [.bitcoin]),
                    AddressChains(address: "eth1", chains: [.ethereum])
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(walletId: "wallet1", chains: [.bitcoin])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.count == 1)
        #expect(changes.toAdd[0].walletId == "wallet1")
        #expect(changes.toAdd[0].subscriptions.count == 1)
        #expect(changes.toAdd[0].subscriptions[0].chains == [Chain.ethereum])
        #expect(changes.toDelete.isEmpty)
    }

    @Test
    func removeChainFromExisting() {
        let local = [
            WalletSubscription(
                walletId: "wallet1",
                source: .import,
                subscriptions: [
                    AddressChains(address: "btc1", chains: [.bitcoin])
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(walletId: "wallet1", chains: [.bitcoin, .ethereum])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.isEmpty)
        #expect(changes.toDelete.count == 1)
        #expect(changes.toDelete[0].walletId == "wallet1")
        #expect(changes.toDelete[0].chains == [Chain.ethereum])
    }

    @Test
    func deleteEntireWallet() {
        let local: [WalletSubscription] = []
        let remote = [
            WalletSubscriptionChains(walletId: "wallet1", chains: [.bitcoin, .ethereum])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.isEmpty)
        #expect(changes.toDelete.count == 1)
        #expect(changes.toDelete[0].walletId == "wallet1")
        #expect(Set(changes.toDelete[0].chains) == Set([Chain.bitcoin, Chain.ethereum]))
    }

    @Test
    func addNewWallet() {
        let local = [
            WalletSubscription(
                walletId: "wallet1",
                source: .import,
                subscriptions: [
                    AddressChains(address: "btc1", chains: [.bitcoin]),
                    AddressChains(address: "eth1", chains: [.ethereum])
                ]
            )
        ]
        let remote: [WalletSubscriptionChains] = []

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.count == 1)
        #expect(changes.toAdd[0].walletId == "wallet1")
        #expect(changes.toAdd[0].subscriptions.count == 2)
        #expect(changes.toDelete.isEmpty)
    }

    @Test
    func noChanges() {
        let local = [
            WalletSubscription(
                walletId: "wallet1",
                source: .import,
                subscriptions: [
                    AddressChains(address: "btc1", chains: [.bitcoin]),
                    AddressChains(address: "eth1", chains: [.ethereum])
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(walletId: "wallet1", chains: [.bitcoin, .ethereum])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.isEmpty)
        #expect(changes.toDelete.isEmpty)
        #expect(!changes.hasChanges)
    }

    @Test
    func multipleWalletsWithChanges() {
        let local = [
            WalletSubscription(
                walletId: "wallet1",
                source: .import,
                subscriptions: [
                    AddressChains(address: "btc1", chains: [.bitcoin])
                ]
            ),
            WalletSubscription(
                walletId: "wallet2",
                source: .import,
                subscriptions: [
                    AddressChains(address: "eth1", chains: [.ethereum]),
                    AddressChains(address: "poly1", chains: [.polygon])
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(walletId: "wallet1", chains: [.bitcoin, .ethereum]),
            WalletSubscriptionChains(walletId: "wallet3", chains: [.solana])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.count == 1)
        #expect(changes.toAdd[0].walletId == "wallet2")

        #expect(changes.toDelete.count == 2)
        let deleteWalletIds = changes.toDelete.map(\.walletId).sorted()
        #expect(deleteWalletIds == ["wallet1", "wallet3"])

        let wallet1Delete = changes.toDelete.first { $0.walletId == "wallet1" }
        #expect(wallet1Delete?.chains == [Chain.ethereum])

        let wallet3Delete = changes.toDelete.first { $0.walletId == "wallet3" }
        #expect(wallet3Delete?.chains == [Chain.solana])
    }

    @Test
    func chainOrderDoesNotMatter() {
        let local = [
            WalletSubscription(
                walletId: "wallet1",
                source: .import,
                subscriptions: [
                    AddressChains(address: "eth1", chains: [.ethereum]),
                    AddressChains(address: "btc1", chains: [.bitcoin])
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(walletId: "wallet1", chains: [.bitcoin, .ethereum])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.isEmpty)
        #expect(changes.toDelete.isEmpty)
        #expect(!changes.hasChanges)
    }
}
