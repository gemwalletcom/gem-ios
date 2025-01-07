// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BannerService
import ChainService
import DeviceService
import PriceAlertService
import StakeService
import NotificationService
import GemstonePrimitives
import NodeService
import WalletConnector
import Store
import GemAPI
import Keystore

struct ServicesFactory {
    @MainActor
    func makeServices(storages: AppResolver.Storages) -> AppResolver.Services {
        let storeManager = StoreManager(db: storages.db)
        let apiService: GemAPIService = GemAPIService()

        let subscriptionService = Self.makeSubscriptionService(
            apiService: apiService,
            walletStore: storeManager.walletStore
        )
        let deviceService = Self.makeDeviceService(
            apiService: apiService,
            subscriptionService: subscriptionService
        )
        let deviceObserverService = Self.makeDeviceObserverService(
            deviceService: deviceService,
            subscriptionService: subscriptionService,
            walletStore: storeManager.walletStore
        )

        let nodeService = NodeService(nodeStore: storeManager.nodeStore)
        let chainServiceFactory = ChainServiceFactory(nodeProvider: nodeService)

        let walletService = Self.makeWalletService(
            keystore: storages.keystore,
            walletStore: storeManager.walletStore
        )
        let balanceService = Self.makeBalanceService(
            balanceStore: storeManager.balanceStore,
            chainFactory: chainServiceFactory
        )
        let stakeService = Self.makeStakeService(
            stakeStore: storeManager.stakeStore,
            chainFactory: chainServiceFactory
        )
        let assetsService = Self.makeAssetsService(
            assetStore: storeManager.assetStore,
            balanceStore: storeManager.balanceStore,
            chainFactory: chainServiceFactory
        )

        let transactionsService = Self.makeTransactionsService(
            transactionStore: storeManager.transactionStore,
            assetsService: assetsService,
            keystore: storages.keystore
        )
        let transactionService = Self.makeTransactionService(
            transactionStore: storeManager.transactionStore,
            stakeService: stakeService,
            chainFactory: chainServiceFactory,
            balanceService: balanceService
        )

        let preferences = storages.observablePreferences.preferences
        let bannerService = Self.makeBannerService(
            bannerStore: storeManager.bannerStore,
            preferences: preferences
        )
        let notificationService = NotificationService()

        let priceAlertService = Self.makePriceAlertService(
            priceAlertStore: storeManager.priceAlertStore,
            deviceService: deviceService,
            preferences: preferences
        )
        let priceService = PriceService(
            priceStore: storeManager.priceStore,
            preferences: preferences
        )
        let explorerService = ExplorerService(storage: storages.explorerStore)

        let presenter = WalletConnectorPresenter()
        let walletConnectorManager = WalletConnectorManager(presenter: presenter)
        let connectionsService = Self.makeConnectionsService(
            connectionsStore: storeManager.connectionsStore,
            keystore: storages.keystore,
            interactor: walletConnectorManager
        )

        let bannerSetupService = BannerSetupService(
            store: storeManager.bannerStore,
            preferences: preferences
        )
        let walletsService = Self.makeWalletsService(
            keystore: storages.keystore,
            priceStore: storeManager.priceStore,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            transactionService: transactionService,
            chainServiceFactory: chainServiceFactory,
            bannerSetupService: bannerSetupService
        )

        let onstartService = Self.makeOnstartService(
            assetStore: storeManager.assetStore,
            keystore: storages.keystore,
            nodeStore: storeManager.nodeStore,
            preferences: preferences,
            assetsService: assetsService,
            deviceService: deviceService,
            subscriptionService: subscriptionService,
            bannerSetupService: bannerSetupService
        )

        return AppResolver.Services(
            assetsService: assetsService,
            balanceService: balanceService,
            bannerService: bannerService,
            chainServiceFactory: chainServiceFactory,
            connectionsService: connectionsService,
            deviceService: deviceService,
            nodeService: nodeService,
            notificationService: notificationService,
            priceAlertService: priceAlertService,
            priceService: priceService,
            stakeService: stakeService,
            subscriptionService: subscriptionService,
            transactionsService: transactionsService,
            transactionService: transactionService,
            walletService: walletService,
            walletsService: walletsService,
            explorerService: explorerService,
            deviceObserverService: deviceObserverService,
            onstartService: onstartService,
            walletConnectorManager: walletConnectorManager
        )
    }
}

// MARK: - Private Static

extension ServicesFactory {
    private static func makeSubscriptionService(
        apiService: GemAPIService,
        walletStore: WalletStore
    ) -> SubscriptionService {
        SubscriptionService(
            subscriptionProvider: apiService,
            walletStore: walletStore
        )
    }

    private static func makeDeviceService(
        apiService: GemAPIService,
        subscriptionService: SubscriptionService
    ) -> DeviceService {
        DeviceService(
            deviceProvider: apiService,
            subscriptionsService: subscriptionService
        )
    }

    private static func makeDeviceObserverService(
        deviceService: DeviceService,
        subscriptionService: SubscriptionService,
        walletStore: WalletStore
    ) -> DeviceObserverService {
        DeviceObserverService(
            deviceService: deviceService,
            subscriptionsService: subscriptionService,
            subscriptionsObserver: walletStore.observer()
        )
    }

    private static func makeWalletService(
        keystore: any Keystore,
        walletStore: WalletStore
    ) -> WalletService {
        WalletService(
            keystore: keystore,
            walletStore: walletStore
        )
    }

    private static func makeBalanceService(
        balanceStore: BalanceStore,
        chainFactory: ChainServiceFactory
    ) -> BalanceService {
        BalanceService(
            balanceStore: balanceStore,
            chainServiceFactory: chainFactory
        )
    }

    private static func makeStakeService(
        stakeStore: StakeStore,
        chainFactory: ChainServiceFactory
    ) -> StakeService {
        StakeService(
            store: stakeStore,
            chainServiceFactory: chainFactory
        )
    }

    private static func makeAssetsService(
        assetStore: AssetStore,
        balanceStore: BalanceStore,
        chainFactory: ChainService.ChainServiceFactory
    ) -> AssetsService {
        AssetsService(
            assetStore: assetStore,
            balanceStore: balanceStore,
            chainServiceFactory: chainFactory
        )
    }

    private static func makeTransactionsService(
        transactionStore: TransactionStore,
        assetsService: AssetsService,
        keystore: any Keystore
    ) -> TransactionsService {
        TransactionsService(
            transactionStore: transactionStore,
            assetsService: assetsService,
            keystore: keystore
        )
    }

    private static func makeTransactionService(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        chainFactory: ChainService.ChainServiceFactory,
        balanceService: BalanceService
    ) -> TransactionService {
        TransactionService(
            transactionStore: transactionStore,
            stakeService: stakeService,
            chainServiceFactory: chainFactory,
            balanceUpdater: balanceService
        )
    }

    private static func makeBannerService(
        bannerStore: BannerStore,
        preferences: Preferences
    ) -> BannerService {
        BannerService(
            store: bannerStore,
            pushNotificationService: PushNotificationEnablerService(preferences: preferences)
        )
    }

    private static func makePriceAlertService(
        priceAlertStore: PriceAlertStore,
        deviceService: DeviceService,
        preferences: Store.Preferences
    ) -> PriceAlertService {
        PriceAlertService(
            store: priceAlertStore,
            deviceService: deviceService,
            preferences: preferences
        )
    }

    private static func makeConnectionsService(
        connectionsStore: ConnectionsStore,
        keystore: any Keystore,
        interactor: any WalletConnectorInteractable
    ) -> ConnectionsService {
        let signer = WalletConnectorSigner(
            store: connectionsStore,
            keystore: keystore,
            walletConnectorInteractor: interactor
        )
        return ConnectionsService(
            store: connectionsStore,
            signer: signer
        )
    }

    private static func makeWalletsService(
        keystore: any Keystore,
        priceStore: PriceStore,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceService: PriceService,
        transactionService: TransactionService,
        chainServiceFactory: ChainServiceFactory,
        bannerSetupService: BannerSetupService
    ) -> WalletsService {
        WalletsService(
            keystore: keystore,
            priceStore: priceStore,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            discoverAssetService: DiscoverAssetsService(
                balanceService: balanceService,
                chainServiceFactory: chainServiceFactory
            ),
            transactionService: transactionService,
            bannerSetupService: bannerSetupService,
            addressStatusService: AddressStatusService(chainServiceFactory: chainServiceFactory)
        )
    }

    private static func makeOnstartService(
        assetStore: AssetStore,
        keystore: any Keystore,
        nodeStore: NodeStore,
        preferences: Preferences,
        assetsService: AssetsService,
        deviceService: DeviceService,
        subscriptionService: SubscriptionService,
        bannerSetupService: BannerSetupService
    ) -> OnstartAsyncService {
        OnstartAsyncService(
            assetStore: assetStore,
            keystore: keystore,
            nodeStore: nodeStore,
            preferences: preferences,
            assetsService: assetsService,
            deviceService: deviceService,
            subscriptionService: subscriptionService,
            bannerSetupService: bannerSetupService
        )
    }
}
