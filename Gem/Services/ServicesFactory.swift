// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
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
import TransactionStateService
import NFTService
import WalletService
import AvatarService
import WalletSessionService
import ScanService
import SwapService
import NameService
import PerpetualService
import WalletsService
import AppService
import AddressNameService
import Blockchain
import NativeProviderService
import ActivityService
import AuthService
import RewardsService
import EventPresenterService

struct ServicesFactory {
    func makeServices(storages: AppResolver.Storages, navigation: NavigationStateManager) -> AppResolver.Services {
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
        let nativeProvider = NativeProvider(nodeProvider: nodeService)
        let gatewayService = GatewayService(provider: nativeProvider)
        let chainServiceFactory = ChainServiceFactory(nodeProvider: nodeService)

        let avatarService = AvatarService(store: storeManager.walletStore)
        let assetsService = Self.makeAssetsService(
            assetStore: storeManager.assetStore,
            balanceStore: storeManager.balanceStore,
            chainFactory: chainServiceFactory
        )

        let walletService = Self.makeWalletService(
            preferences: storages.observablePreferences,
            keystore: storages.keystore,
            walletStore: storeManager.walletStore,
            avatarService: avatarService
        )
        let balanceService = Self.makeBalanceService(
            balanceStore: storeManager.balanceStore,
            assetsService: assetsService,
            chainFactory: chainServiceFactory
        )
        let stakeService = Self.makeStakeService(
            stakeStore: storeManager.stakeStore,
            addressStore: storeManager.addressStore,
            chainFactory: chainServiceFactory
        )
        let nftService = Self.makeNftService(
            apiService: apiService,
            nftStore: storeManager.nftStore,
            deviceService: deviceService
        )
        let transactionsService = Self.makeTransactionsService(
            transactionStore: storeManager.transactionStore,
            assetsService: assetsService,
            walletStore: storeManager.walletStore,
            deviceService: deviceService,
            addressStore: storeManager.addressStore
        )
        let transactionStateService = Self.makeTransactionService(
            transactionStore: storeManager.transactionStore,
            stakeService: stakeService,
            nftService: nftService,
            chainFactory: chainServiceFactory,
            balanceService: balanceService
        )

        let preferences = storages.observablePreferences.preferences
        let pushNotificationEnablerService = PushNotificationEnablerService(preferences: preferences)
        let bannerSetupService = BannerSetupService(store: storeManager.bannerStore, preferences: preferences)
        let bannerService = Self.makeBannerService(
            bannerStore: storeManager.bannerStore,
            pushNotificationEnablerService: pushNotificationEnablerService
        )
        let navigationPresenter = NavigationPresenter()
        let navigationHandler = NavigationHandler(
            navigationState: navigation,
            presenter: navigationPresenter,
            assetsService: assetsService,
            transactionsService: transactionsService,
            walletService: walletService
        )

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
        let swapService = SwapService(nodeProvider: nodeService)

        let walletSessionService = WalletSessionService(
            walletStore: storeManager.walletStore,
            preferences: storages.observablePreferences
        )
        let presenter = WalletConnectorPresenter()
        let walletConnectorManager = WalletConnectorManager(presenter: presenter)
        let connectionsService = Self.makeConnectionsService(
            connectionsStore: storeManager.connectionsStore,
            walletSessionService: walletSessionService,
            interactor: walletConnectorManager
        )

        let walletsService = Self.makeWalletsService(
            walletSessionService: walletSessionService,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserverService,
            deviceService: deviceService
        )

        let configService = ConfigService(apiService: apiService)
        let releaseService = AppReleaseService(configService: configService)
        let releaseAlertService = ReleaseAlertService(
            appReleaseService: releaseService,
            preferences: preferences
        )
        let rateService = RateService(preferences: preferences)

        let onStartService = Self.makeOnstartService(
            assetStore: storeManager.assetStore,
            nodeStore: storeManager.nodeStore,
            preferences: preferences,
            assetsService: assetsService,
            walletService: walletService
        )
        let onstartAsyncService = Self.makeOnstartAsyncService(
            nodeService: nodeService,
            preferences: preferences,
            assetsService: assetsService,
            bannerSetupService: bannerSetupService,
            configService: configService,
            swappableChainsProvider: swapService
        )
        let onstartWalletService = Self.makeOnstartWalletService(
            preferences: preferences,
            deviceService: deviceService,
            bannerSetupService: bannerSetupService,
            addressStatusService: AddressStatusService(chainServiceFactory: chainServiceFactory),
            pushNotificationEnablerService: pushNotificationEnablerService
        )

        let perpetualService = Self.makePerpetualService(
            perpetualStore: storeManager.perpetualStore,
            assetStore: storeManager.assetStore,
            priceAstore: storeManager.priceStore,
            balanceStore: storeManager.balanceStore,
            nodeProvider: nodeService,
            preferences: preferences
        )
        let hyperliquidObserverService = HyperliquidObserverService(
            nodeProvider: PerpetualNodeService(preferences: preferences),
            perpetualService: perpetualService
        )

        let nameService = NameService()
        let scanService = ScanService(gatewayService: gatewayService)
        let addressNameService = AddressNameService(addressStore: storeManager.addressStore)
        let activityService = ActivityService(store: storeManager.recentActivityStore)
        let authService = AuthService(keystore: storages.keystore)
        let rewardsService = RewardsService(authService: authService)
        let eventPresenterService = EventPresenterService()
        let inAppNotificationService = InAppNotificationService(
            deviceService: deviceService,
            walletService: walletService,
            store: storeManager.inAppNotificationStore
        )

        let observersService = ObserversService(
            connectionsService: connectionsService,
            deviceObserverService: deviceObserverService,
            priceObserverService: priceObserverService,
            hyperliquidObserverService: hyperliquidObserverService
        )

        let viewModelFactory = ViewModelFactory(
            keystore: storages.keystore,
            nodeService: nodeService,
            scanService: scanService,
            swapService: swapService,
            walletsService: walletsService,
            walletService: walletService,
            stakeService: stakeService,
            nameService: nameService,
            balanceService: balanceService,
            priceService: priceService,
            transactionStateService: transactionStateService,
            chainServiceFactory: chainServiceFactory,
            addressNameService: addressNameService,
            activityService: activityService,
            eventPresenterService: eventPresenterService
        )

        return AppResolver.Services(
            assetsService: assetsService,
            balanceService: balanceService,
            bannerService: bannerService,
            chainServiceFactory: chainServiceFactory,
            connectionsService: connectionsService,
            deviceService: deviceService,
            nodeService: nodeService,
            navigationHandler: navigationHandler,
            navigationPresenter: navigationPresenter,
            priceAlertService: priceAlertService,
            priceObserverService: priceObserverService,
            priceService: priceService,
            stakeService: stakeService,
            transactionsService: transactionsService,
            transactionStateService: transactionStateService,
            walletService: walletService,
            walletsService: walletsService,
            explorerService: explorerService,
            scanService: scanService,
            nftService: nftService,
            avatarService: avatarService,
            swapService: swapService,
            appReleaseService: releaseService,
            releaseAlertService: releaseAlertService,
            rateService: rateService,
            subscriptionsService: subscriptionService,
            deviceObserverService: deviceObserverService,
            onstartService: onStartService,
            onstartAsyncService: onstartAsyncService,
            onstartWalletService: onstartWalletService,
            walletConnectorManager: walletConnectorManager,
            perpetualService: perpetualService,
            hyperliquidObserverService: hyperliquidObserverService,
            nameService: nameService,
            addressNameService: addressNameService,
            activityService: activityService,
            eventPresenterService: eventPresenterService,
            viewModelFactory: viewModelFactory,
            rewardsService: rewardsService,
            observersService: observersService,
            inAppNotificationService: inAppNotificationService
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
        deviceService: any DeviceServiceable,
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
        assetsService: AssetsService,
        chainFactory: ChainServiceFactory
    ) -> BalanceService {
        BalanceService(
            balanceStore: balanceStore,
            assetsService: assetsService,
            chainServiceFactory: chainFactory
        )
    }

    private static func makeStakeService(
        stakeStore: StakeStore,
        addressStore: AddressStore,
        chainFactory: ChainServiceFactory
    ) -> StakeService {
        StakeService(
            store: stakeStore,
            addressStore: addressStore,
            chainServiceFactory: chainFactory
        )
    }

    private static func makeAssetsService(
        assetStore: AssetStore,
        balanceStore: BalanceStore,
        chainFactory: ChainServiceFactory
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
        walletStore: WalletStore,
        deviceService: any DeviceServiceable,
        addressStore: AddressStore
    ) -> TransactionsService {
        TransactionsService(
            transactionStore: transactionStore,
            assetsService: assetsService,
            walletStore: walletStore,
            deviceService: deviceService,
            addressStore: addressStore
        )
    }

    private static func makeTransactionService(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        nftService: NFTService,
        chainFactory: ChainServiceFactory,
        balanceService: BalanceService
    ) -> TransactionStateService {
        TransactionStateService(
            transactionStore: transactionStore,
            stakeService: stakeService,
            nftService: nftService,
            chainServiceFactory: chainFactory,
            balanceUpdater: balanceService
        )
    }

    private static func makeBannerService(
        bannerStore: BannerStore,
        pushNotificationEnablerService: PushNotificationEnablerService
    ) -> BannerService {
        BannerService(
            store: bannerStore,
            pushNotificationService: pushNotificationEnablerService
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
        ConnectionsService(
            store: connectionsStore,
            signer: WalletConnectorSigner(
                connectionsStore: connectionsStore,
                walletSessionService: walletSessionService,
                walletConnectorInteractor: interactor
            )
        )
    }

    private static func makeWalletsService(
        walletSessionService: WalletSessionService,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceService: PriceService,
        priceObserver: PriceObserverService,
        deviceService: DeviceService
    ) -> WalletsService {
        WalletsService(
            walletSessionService: walletSessionService,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserver,
            deviceService: deviceService
        )
    }

    private static func makeOnstartService(
        assetStore: AssetStore,
        nodeStore: NodeStore,
        preferences: Preferences,
        assetsService: AssetsService,
        walletService: WalletService
    ) -> OnstartService {
        OnstartService(
            assetsService: assetsService,
            assetStore: assetStore,
            nodeStore: nodeStore,
            preferences: preferences,
            walletService: walletService
        )
    }

    private static func makeOnstartAsyncService(
        nodeService: NodeService,
        preferences: Preferences,
        assetsService: AssetsService,
        bannerSetupService: BannerSetupService,
        configService: ConfigService,
        swappableChainsProvider: any SwappableChainsProvider
    ) -> OnstartAsyncService {
        let importAssetsService = ImportAssetsService(
            assetsService: assetsService,
            assetStore: assetsService.assetStore,
            preferences: preferences
        )

        return OnstartAsyncService(
            runners: [
                ConfigUpdateRunner(configService: configService),
                BannerSetupRunner(bannerSetupService: bannerSetupService),
                NodeImportRunner(nodeService: nodeService),
                AssetsUpdateRunner(
                    configService: configService,
                    importAssetsService: importAssetsService,
                    assetsService: assetsService,
                    swappableChainsProvider: swappableChainsProvider,
                    preferences: preferences
                ),
            ]
        )
    }

    private static func makeOnstartWalletService(
        preferences: Preferences,
        deviceService: DeviceService,
        bannerSetupService: BannerSetupService,
        addressStatusService: AddressStatusService,
        pushNotificationEnablerService: PushNotificationEnablerService
    ) -> OnstartWalletService {
        OnstartWalletService(
            preferences: preferences,
            deviceService: deviceService,
            bannerSetupService: bannerSetupService,
            addressStatusService: addressStatusService,
            pushNotificationEnablerService: pushNotificationEnablerService
        )
    }
    
    private static func makeNftService(
        apiService: GemAPIService,
        nftStore: NFTStore,
        deviceService: any DeviceServiceable
    ) -> NFTService {
        NFTService(
            apiService: apiService,
            nftStore: nftStore,
            deviceService: deviceService
        )
    }
    
    private static func makePerpetualService(
        perpetualStore: PerpetualStore,
        assetStore: AssetStore,
        priceAstore: PriceStore,
        balanceStore: BalanceStore,
        nodeProvider: any NodeURLFetchable,
        preferences: Preferences
    ) -> PerpetualService {
        PerpetualService(
            store: perpetualStore,
            assetStore: assetStore,
            priceStore: priceAstore,
            balanceStore: balanceStore,
            provider: PerpetualProviderFactory(nodeProvider: nodeProvider).createProvider(),
            preferences: preferences
        )
    }
}
