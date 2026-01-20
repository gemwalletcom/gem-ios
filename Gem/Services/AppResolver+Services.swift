// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BannerService
import ChainService
import DeviceService
import PriceAlertService
import StakeService
import NodeService
import PriceService
import WalletConnector
import ExplorerService
import BalanceService
import AssetsService
import TransactionsService
import TransactionStateService
import WalletsService
import WalletService
import AppService
import ScanService
import NFTService
import AvatarService
import SwapService
import NameService
import PerpetualService
import AddressNameService
import ActivityService
import RewardsService
import EventPresenterService
import NotificationService
import YieldService

extension AppResolver {
    struct Services: Sendable {
        // Environment-level services
        let assetsService: AssetsService
        let balanceService: BalanceService
        let bannerService: BannerService
        let chainServiceFactory: ChainServiceFactory
        let connectionsService: ConnectionsService
        let deviceService: DeviceService
        let nodeService: NodeService
        let navigationHandler: NavigationHandler
        let navigationPresenter: NavigationPresenter
        let priceAlertService: PriceAlertService
        let priceService: PriceService
        let priceObserverService: PriceObserverService
        let stakeService: StakeService
        let transactionsService: TransactionsService
        let transactionStateService: TransactionStateService
        let walletService: WalletService
        let walletsService: WalletsService
        let explorerService: ExplorerService
        let scanService: ScanService
        let nftService: NFTService
        let avatarService: AvatarService
        let swapService: SwapService
        let subscriptionsService: SubscriptionService
        let appReleaseService: AppReleaseService
        let releaseAlertService: ReleaseAlertService
        let rateService: RateService
        let deviceObserverService: DeviceObserverService
        let onstartService: OnstartService
        let onstartAsyncService: OnstartAsyncService
        let onstartWalletService: OnstartWalletService
        let walletConnectorManager: WalletConnectorManager
        let perpetualService: PerpetualService
        let perpetualObserverService: PerpetualObserverService
        let nameService: NameService
        let addressNameService: AddressNameService
        let activityService: ActivityService
        let eventPresenterService: EventPresenterService
        let viewModelFactory: ViewModelFactory
        let rewardsService: RewardsService
        let observersService: ObserversService
        let inAppNotificationService: InAppNotificationService
        let yieldService: YieldService?

        init(
            assetsService: AssetsService,
            balanceService: BalanceService,
            bannerService: BannerService,
            chainServiceFactory: ChainServiceFactory,
            connectionsService: ConnectionsService,
            deviceService: DeviceService,
            nodeService: NodeService,
            navigationHandler: NavigationHandler,
            navigationPresenter: NavigationPresenter,
            priceAlertService: PriceAlertService,
            priceObserverService: PriceObserverService,
            priceService: PriceService,
            stakeService: StakeService,
            transactionsService: TransactionsService,
            transactionStateService: TransactionStateService,
            walletService: WalletService,
            walletsService: WalletsService,
            explorerService: ExplorerService,
            scanService: ScanService,
            nftService: NFTService,
            avatarService: AvatarService,
            swapService: SwapService,
            appReleaseService: AppReleaseService,
            releaseAlertService: ReleaseAlertService,
            rateService: RateService,
            subscriptionsService: SubscriptionService,
            deviceObserverService: DeviceObserverService,
            onstartService: OnstartService,
            onstartAsyncService: OnstartAsyncService,
            onstartWalletService: OnstartWalletService,
            walletConnectorManager: WalletConnectorManager,
            perpetualService: PerpetualService,
            perpetualObserverService: PerpetualObserverService,
            nameService: NameService,
            addressNameService: AddressNameService,
            activityService: ActivityService,
            eventPresenterService: EventPresenterService,
            viewModelFactory: ViewModelFactory,
            rewardsService: RewardsService,
            observersService: ObserversService,
            inAppNotificationService: InAppNotificationService,
            yieldService: YieldService?
        ) {
            self.assetsService = assetsService
            self.balanceService = balanceService
            self.bannerService = bannerService
            self.chainServiceFactory = chainServiceFactory
            self.connectionsService = connectionsService
            self.deviceService = deviceService
            self.nodeService = nodeService
            self.navigationHandler = navigationHandler
            self.navigationPresenter = navigationPresenter
            self.priceAlertService = priceAlertService
            self.priceService = priceService
            self.priceObserverService = priceObserverService
            self.stakeService = stakeService
            self.transactionsService = transactionsService
            self.transactionStateService = transactionStateService
            self.walletService = walletService
            self.walletsService = walletsService
            self.explorerService = explorerService
            self.scanService = scanService
            self.nftService = nftService
            self.avatarService = avatarService
            self.swapService = swapService
            self.appReleaseService = appReleaseService
            self.releaseAlertService = releaseAlertService
            self.rateService = rateService
            self.deviceObserverService = deviceObserverService
            self.subscriptionsService = subscriptionsService
            self.onstartService = onstartService
            self.onstartAsyncService = onstartAsyncService
            self.onstartWalletService = onstartWalletService
            self.walletConnectorManager = walletConnectorManager
            self.perpetualService = perpetualService
            self.perpetualObserverService = perpetualObserverService
            self.nameService = nameService
            self.addressNameService = addressNameService
            self.activityService = activityService
            self.eventPresenterService = eventPresenterService
            self.viewModelFactory = viewModelFactory
            self.rewardsService = rewardsService
            self.observersService = observersService
            self.inAppNotificationService = inAppNotificationService
            self.yieldService = yieldService
        }
    }
}
