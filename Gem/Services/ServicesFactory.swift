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
import TransactionService
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

        let avatarService = AvatarService(store: storeManager.walletStore)
        let assetsService = Self.makeAssetsService(
            assetStore: storeManager.assetStore,
            balanceStore: storeManager.balanceStore,
            chainFactory: chainServiceFactory
        )

        let walletService = Self.makewalletService(
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
        let notificationHandler = NotificationHandler()

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

        let walletsService = Self.makeWalletsService(
            walletStore: storeManager.walletStore,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserverService,
            deviceService: deviceService
        )

        let configService = GemAPIService()
        let releaseService = AppReleaseService(configService: configService)

        let onStartService = Self.makeOnstartService(
            assetStore: storeManager.assetStore,
            nodeStore: storeManager.nodeStore,
            balanceStore: storeManager.balanceStore,
            preferences: preferences,
            chainServiceFactory: chainServiceFactory,
            walletService: walletService
        )
        let onstartAsyncService = Self.makeOnstartAsyncService(
            assetStore: storeManager.assetStore,
            nodeStore: storeManager.nodeStore,
            bannerStore: storeManager.bannerStore,
            preferences: preferences,
            assetsService: assetsService,
            deviceService: deviceService,
            configService: configService,
            releaseService: AppReleaseService(configService: configService),
            addressStatusService: AddressStatusService(chainServiceFactory: chainServiceFactory)
        )

        let perpetualService = Self.makePerpetualService(
            perpetualStore: storeManager.perpetualStore,
            assetStore: storeManager.assetStore,
            priceAstore: storeManager.priceStore,
            balanceStore: storeManager.balanceStore,
            nodeProvider: nodeService
        )
        let perpetualObserverService = PerpetualObserverService(perpetualService: perpetualService)
        
        let nameService = NameService()
        let scanService = ScanService(securePreferences: .standard)
        let addressNameService = AddressNameService(addressStore: storeManager.addressStore)
        
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
            transactionService: transactionService,
            chainServiceFactory: chainServiceFactory,
            addressNameService: addressNameService
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
            scanService: scanService,
            nftService: nftService,
            avatarService: avatarService,
            swapService: swapService,
            appReleaseService: releaseService,
            subscriptionsService: subscriptionService,
            deviceObserverService: deviceObserverService,
            onstartService: onStartService,
            onstartAsyncService: onstartAsyncService,
            walletConnectorManager: walletConnectorManager,
            perpetualService: perpetualService,
            perpetualObserverService: perpetualObserverService,
            nameService: nameService,
            addressNameService: addressNameService,
            viewModelFactory: viewModelFactory
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
        deviceService: DeviceService
    ) -> WalletsService {
        WalletsService(
            walletStore: walletStore,
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
        balanceStore: BalanceStore,
        preferences: Preferences,
        chainServiceFactory: ChainServiceFactory,
        walletService: WalletService
    ) -> OnstartService {
        OnstartService(
            assetsService: AssetsService(
                assetStore: assetStore,
                balanceStore: balanceStore,
                chainServiceFactory: chainServiceFactory
            ),
            assetStore: assetStore,
            nodeStore: nodeStore,
            preferences: preferences,
            walletService: walletService
        )
    }

    private static func makeOnstartAsyncService(
        assetStore: AssetStore,
        nodeStore: NodeStore,
        bannerStore: BannerStore,
        preferences: Preferences,
        assetsService: AssetsService,
        deviceService: DeviceService,
        configService: any GemAPIConfigService,
        releaseService: AppReleaseService,
        addressStatusService: AddressStatusService
    ) -> OnstartAsyncService {
        let bannerSetupService = BannerSetupService(
            store: bannerStore,
            preferences: preferences
        )
        return OnstartAsyncService(
            assetStore: assetStore,
            nodeStore: nodeStore,
            preferences: preferences,
            assetsService: assetsService,
            deviceService: deviceService,
            bannerSetupService: bannerSetupService,
            configService: configService,
            releaseService: releaseService,
            addressStatusService: addressStatusService
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
        nodeProvider: any NodeURLFetchable
    ) -> PerpetualService {
        let providerFactory = PerpetualProviderFactory(nodeProvider: nodeProvider)
        
        return PerpetualService(
            store: perpetualStore,
            assetStore: assetStore,
            priceStore: priceAstore,
            balanceStore: balanceStore,
            provider: providerFactory.createProvider()
        )
    }
}
