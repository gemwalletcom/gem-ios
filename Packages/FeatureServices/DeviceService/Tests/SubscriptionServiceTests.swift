// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import DeviceService

struct SubscriptionServiceTests {
    @Test
    func addNewChainToExisting() {
        let local = [
            WalletSubscription(
                wallet_id: "wallet1",
                source: .import,
                subscriptions: [
                    ChainAddress(chain: .bitcoin, address: "btc1"),
                    ChainAddress(chain: .ethereum, address: "eth1")
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(wallet_id: "wallet1", chains: [.bitcoin])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.count == 1)
        #expect(changes.toAdd[0].wallet_id == "wallet1")
        #expect(changes.toAdd[0].subscriptions.count == 1)
        #expect(changes.toAdd[0].subscriptions[0].chain == .ethereum)
        #expect(changes.toDelete.isEmpty)
    }

    @Test
    func removeChainFromExisting() {
        let local = [
            WalletSubscription(
                wallet_id: "wallet1",
                source: .import,
                subscriptions: [
                    ChainAddress(chain: .bitcoin, address: "btc1")
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(wallet_id: "wallet1", chains: [.bitcoin, .ethereum])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.isEmpty)
        #expect(changes.toDelete.count == 1)
        #expect(changes.toDelete[0].wallet_id == "wallet1")
        #expect(changes.toDelete[0].chains == [.ethereum])
    }

    @Test
    func deleteEntireWallet() {
        let local: [WalletSubscription] = []
        let remote = [
            WalletSubscriptionChains(wallet_id: "wallet1", chains: [.bitcoin, .ethereum])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.isEmpty)
        #expect(changes.toDelete.count == 1)
        #expect(changes.toDelete[0].wallet_id == "wallet1")
        #expect(changes.toDelete[0].chains.sorted() == [.bitcoin, .ethereum].sorted())
    }

    @Test
    func addNewWallet() {
        let local = [
            WalletSubscription(
                wallet_id: "wallet1",
                source: .import,
                subscriptions: [
                    ChainAddress(chain: .bitcoin, address: "btc1"),
                    ChainAddress(chain: .ethereum, address: "eth1")
                ]
            )
        ]
        let remote: [WalletSubscriptionChains] = []

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.count == 1)
        #expect(changes.toAdd[0].wallet_id == "wallet1")
        #expect(changes.toAdd[0].subscriptions.count == 2)
        #expect(changes.toDelete.isEmpty)
    }

    @Test
    func noChanges() {
        let local = [
            WalletSubscription(
                wallet_id: "wallet1",
                source: .import,
                subscriptions: [
                    ChainAddress(chain: .bitcoin, address: "btc1"),
                    ChainAddress(chain: .ethereum, address: "eth1")
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(wallet_id: "wallet1", chains: [.bitcoin, .ethereum])
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
                wallet_id: "wallet1",
                source: .import,
                subscriptions: [
                    ChainAddress(chain: .bitcoin, address: "btc1")
                ]
            ),
            WalletSubscription(
                wallet_id: "wallet2",
                source: .import,
                subscriptions: [
                    ChainAddress(chain: .ethereum, address: "eth1"),
                    ChainAddress(chain: .polygon, address: "poly1")
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(wallet_id: "wallet1", chains: [.bitcoin, .ethereum]),
            WalletSubscriptionChains(wallet_id: "wallet3", chains: [.solana])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.count == 1)
        #expect(changes.toAdd[0].wallet_id == "wallet2")

        #expect(changes.toDelete.count == 2)
        let deleteWalletIds = changes.toDelete.map(\.wallet_id).sorted()
        #expect(deleteWalletIds == ["wallet1", "wallet3"])

        let wallet1Delete = changes.toDelete.first { $0.wallet_id == "wallet1" }
        #expect(wallet1Delete?.chains == [.ethereum])

        let wallet3Delete = changes.toDelete.first { $0.wallet_id == "wallet3" }
        #expect(wallet3Delete?.chains == [.solana])
    }

    @Test
    func chainOrderDoesNotMatter() {
        let local = [
            WalletSubscription(
                wallet_id: "wallet1",
                source: .import,
                subscriptions: [
                    ChainAddress(chain: .ethereum, address: "eth1"),
                    ChainAddress(chain: .bitcoin, address: "btc1")
                ]
            )
        ]
        let remote = [
            WalletSubscriptionChains(wallet_id: "wallet1", chains: [.bitcoin, .ethereum])
        ]

        let changes = SubscriptionService.calculateChanges(local: local, remote: remote)

        #expect(changes.toAdd.isEmpty)
        #expect(changes.toDelete.isEmpty)
        #expect(!changes.hasChanges)
    }
}
