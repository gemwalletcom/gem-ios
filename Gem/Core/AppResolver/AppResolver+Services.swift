// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BannerService
import ChainService
import DeviceService
import PriceAlertService
import StakeService
import NotificationService
import GemstonePrimitives
import Store
import GemAPI

extension AppResolver {
    struct Services {
        // Environment-level services
        let assetsService: AssetsService
        let balanceService: BalanceService
        let bannerService: BannerService
        let chainServiceFactory: ChainServiceFactory
        let connectionsService: ConnectionsService
        let deviceService: DeviceService
        let nodeService: NodeService
        let notificationService: NotificationService
        let priceAlertService: PriceAlertService
        let priceService: PriceService
        let stakeService: StakeService
        let subscriptionService: SubscriptionService
        let transactionsService: TransactionsService
        let transactionService: TransactionService
        let walletService: WalletService
        let walletsService: WalletsService
        let explorerService: ExplorerService

        let deviceObserverService: DeviceObserverService
        let onstartService: OnstartAsyncService
        let walletConnectorInteractor: WalletConnectorInteractor

        init(stores: Storages) {
            let keystore = stores.keystore
            let preferences = stores.observablePreferences.preferences
            let store: StoreManager = StoreManager(db: stores.db)
            let apiService: GemAPIService = GemAPIService()

            // Subscription & Device
            self.subscriptionService = SubscriptionService(
                subscriptionProvider: apiService,
                walletStore: store.walletStore
            )
            self.deviceService = DeviceService(
                deviceProvider: apiService,
                subscriptionsService: subscriptionService
            )
            self.deviceObserverService = DeviceObserverService(
                deviceService: deviceService,
                subscriptionsService: subscriptionService,
                subscriptionsObserver: store.walletStore.observer()
            )

            // Node & Chain
            self.nodeService = NodeService(nodeStore: store.nodeStore)
            self.chainServiceFactory = ChainServiceFactory(nodeProvider: nodeService)

            // Wallet & Accounts
            self.walletService = WalletService(
                keystore: keystore,
                walletStore: store.walletStore
            )

            // Balances, Assets, and Stake
            self.balanceService = BalanceService(
                balanceStore: store.balanceStore,
                chainServiceFactory: chainServiceFactory
            )
            self.stakeService = StakeService(
                store: store.stakeStore,
                chainServiceFactory: chainServiceFactory
            )
            self.assetsService = AssetsService(
                assetStore: store.assetStore,
                balanceStore: store.balanceStore,
                chainServiceFactory: chainServiceFactory
            )

            // Transactions
            self.transactionsService = TransactionsService(
                transactionStore: store.transactionStore,
                assetsService: assetsService,
                keystore: keystore
            )
            self.transactionService = TransactionService(
                transactionStore: store.transactionStore,
                stakeService: stakeService,
                chainServiceFactory: chainServiceFactory,
                balanceUpdater: balanceService
            )

            // Banner & Notifications
            self.bannerService = BannerService(
                store: store.bannerStore,
                pushNotificationService: PushNotificationEnablerService(preferences: preferences)
            )
            self.notificationService = NotificationService()

            // Price & Alerts
            self.priceAlertService = PriceAlertService(
                store: store.priceAlertStore,
                deviceService: deviceService,
                preferences: preferences
            )
            self.priceService = PriceService(priceStore: store.priceStore, preferences: preferences)

            // Explorer
            self.explorerService = ExplorerService(storage: stores.explorerStore)

            // Wallet Connector & Connections
            let interactor = WalletConnectorInteractor()
            self.walletConnectorInteractor = interactor
            let signer = WalletConnectorSigner(
                store: store.connectionsStore,
                keystore: keystore,
                walletConnectorInteractor: interactor
            )
            self.connectionsService = ConnectionsService(
                store: store.connectionsStore,
                signer: signer
            )

            // Wallets Service
            let bannerSetupService = BannerSetupService(store: store.bannerStore, preferences: preferences)
            self.walletsService = WalletsService(
                keystore: keystore,
                priceStore: store.priceStore,
                assetsService: assetsService,
                balanceService: balanceService,
                stakeService: stakeService,
                priceService: priceService,
                discoverAssetService: DiscoverAssetsService(
                    balanceService: balanceService,
                    chainServiceFactory: chainServiceFactory
                ),
                transactionService: transactionService,
                nodeService: nodeService,
                connectionsService: connectionsService,
                bannerSetupService: bannerSetupService,
                addressStatusService: AddressStatusService(chainServiceFactory: chainServiceFactory)
            )

            // Onstart
            self.onstartService = OnstartAsyncService(
                assetStore: store.assetStore,
                keystore: keystore,
                nodeStore: store.nodeStore,
                preferences: preferences,
                assetsService: assetsService,
                deviceService: deviceService,
                subscriptionService: subscriptionService,
                bannerSetupService: bannerSetupService
            )
        }
    }
}
