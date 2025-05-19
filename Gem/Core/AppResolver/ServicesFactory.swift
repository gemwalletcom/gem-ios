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
import PriceService
import Preferences
import ExplorerService
import BalanceService
import AssetsService
import TransactionsService
import TransactionService
import NFTService
import WalletsService
import WalletService
import AvatarService
import WalletSessionService
import AppService

struct ServicesFactory {
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

        let walletService = Self.makewalletService(
            preferences: storages.observablePreferences,
            keystore: storages.keystore,
            walletStore: storeManager.walletStore,
            avatarService: AvatarService(store: storeManager.walletStore)
        )
        let balanceService = Self.makeBalanceService(
            balanceStore: storeManager.balanceStore,
            assetsStore: storeManager.assetStore,
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
        let nftService = Self.makeNftService(
            apiService: apiService,
            nftStore: storeManager.nftStore
        )
        let transactionsService = Self.makeTransactionsService(
            transactionStore: storeManager.transactionStore,
            assetsService: assetsService,
            walletStore: storeManager.walletStore
        )
        let transactionService = Self.makeTransactionService(
            transactionStore: storeManager.transactionStore,
            stakeService: stakeService,
            nftService: nftService,
            chainFactory: chainServiceFactory,
            balanceService: balanceService
        )

        let preferences = storages.observablePreferences.preferences
        let bannerService = Self.makeBannerService(
            bannerStore: storeManager.bannerStore,
            preferences: preferences
        )
        let notificationHandler = NotificationHandler.main

        let priceService = PriceService(
            priceStore: storeManager.priceStore,
            fiatRateStore: storeManager.fiatRateStore
        )
        let priceObserverService = PriceObserverService(
            priceService: priceService,
            preferences: preferences
        )
        let priceAlertService = Self.makePriceAlertService(
            priceAlertStore: storeManager.priceAlertStore,
            deviceService: deviceService,
            priceObserverService: priceObserverService,
            preferences: preferences
        )
        let explorerService = ExplorerService.standard

        let presenter = WalletConnectorPresenter()
        let walletConnectorManager = WalletConnectorManager(presenter: presenter)
        let connectionsService = Self.makeConnectionsService(
            connectionsStore: storeManager.connectionsStore,
            walletSessionService: WalletSessionService(
                walletStore: storeManager.walletStore,
                preferences: storages.observablePreferences
            ),
            interactor: walletConnectorManager
        )

        let bannerSetupService = BannerSetupService(
            store: storeManager.bannerStore,
            preferences: preferences
        )
        let walletsService = Self.makeWalletsService(
            walletStore: storeManager.walletStore,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserverService,
            transactionService: transactionService,
            chainServiceFactory: chainServiceFactory,
            bannerSetupService: bannerSetupService
        )

        let onstartService = Self.makeOnstartService(
            assetStore: storeManager.assetStore,
            nodeStore: storeManager.nodeStore,
            preferences: preferences,
            assetsService: assetsService,
            deviceService: deviceService,
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
            notificationHandler: notificationHandler,
            priceAlertService: priceAlertService,
            priceObserverService: priceObserverService,
            priceService: priceService,
            stakeService: stakeService,
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

    private static func makewalletService(
        preferences: ObservablePreferences,
        keystore: any Keystore,
        walletStore: WalletStore,
        avatarService: AvatarService
    ) -> WalletService {
        WalletService(
            keystore: keystore,
            walletStore: walletStore,
            preferences: preferences,
            avatarService: avatarService
        )
    }

    private static func makeBalanceService(
        balanceStore: BalanceStore,
        assetsStore: AssetStore,
        chainFactory: ChainServiceFactory
    ) -> BalanceService {
        BalanceService(
            balanceStore: balanceStore,
            assertStore: assetsStore,
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
        walletStore: WalletStore
    ) -> TransactionsService {
        TransactionsService(
            transactionStore: transactionStore,
            assetsService: assetsService,
            walletStore: walletStore
        )
    }

    private static func makeTransactionService(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        nftService: NFTService,
        chainFactory: ChainService.ChainServiceFactory,
        balanceService: BalanceService
    ) -> TransactionService {
        TransactionService(
            transactionStore: transactionStore,
            stakeService: stakeService,
            nftService: nftService,
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
        priceObserverService: PriceObserverService,
        preferences: Preferences
    ) -> PriceAlertService {
        PriceAlertService(
            store: priceAlertStore,
            deviceService: deviceService,
            priceObserverService: priceObserverService,
            preferences: preferences
        )
    }

    private static func makeConnectionsService(
        connectionsStore: ConnectionsStore,
        walletSessionService: WalletSessionService,
        interactor: any WalletConnectorInteractable
    ) -> ConnectionsService {
        let signer = WalletConnectorSigner(
            connectionsStore: connectionsStore,
            walletSessionService: walletSessionService,
            walletConnectorInteractor: interactor
        )
        return ConnectionsService(
            store: connectionsStore,
            signer: signer
        )
    }

    private static func makeWalletsService(
        walletStore: WalletStore,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceService: PriceService,
        priceObserver: PriceObserverService,
        transactionService: TransactionService,
        chainServiceFactory: ChainServiceFactory,
        bannerSetupService: BannerSetupService
    ) -> WalletsService {
        WalletsService(
            walletStore: walletStore,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserver,
            chainService: chainServiceFactory,
            transactionService: transactionService,
            bannerSetupService: bannerSetupService,
            addressStatusService: AddressStatusService(chainServiceFactory: chainServiceFactory)
        )
    }

    private static func makeOnstartService(
        assetStore: AssetStore,
        nodeStore: NodeStore,
        preferences: Preferences,
        assetsService: AssetsService,
        deviceService: DeviceService,
        bannerSetupService: BannerSetupService
    ) -> OnstartAsyncService {
        OnstartAsyncService(
            assetStore: assetStore,
            nodeStore: nodeStore,
            preferences: preferences,
            assetsService: assetsService,
            deviceService: deviceService,
            bannerSetupService: bannerSetupService
        )
    }
    
    private static func makeNftService(
        apiService: GemAPIService,
        nftStore: NFTStore
    ) -> NFTService {
        NFTService(
            apiService: apiService,
            nftStore: nftStore
        )
    }
}
