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
import TransactionService
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
import EventManager

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
        let notificationHandler: NotificationHandler
        let priceAlertService: PriceAlertService
        let priceService: PriceService
        let priceObserverService: PriceObserverService
        let stakeService: StakeService
        let transactionsService: TransactionsService
        let transactionService: TransactionService
        let walletService: WalletService
        let walletsService: WalletsService
        let explorerService: ExplorerService
        let scanService: ScanService
        let nftService: NFTService
        let avatarService: AvatarService
        let swapService: SwapService
        let subscriptionsService: SubscriptionService
        let appReleaseService: AppReleaseService
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
        let eventManager: EventManager
        let viewModelFactory: ViewModelFactory
        let rewardsService: RewardsService

        init(
            assetsService: AssetsService,
            balanceService: BalanceService,
            bannerService: BannerService,
            chainServiceFactory: ChainServiceFactory,
            connectionsService: ConnectionsService,
            deviceService: DeviceService,
            nodeService: NodeService,
            notificationHandler: NotificationHandler,
            priceAlertService: PriceAlertService,
            priceObserverService: PriceObserverService,
            priceService: PriceService,
            stakeService: StakeService,
            transactionsService: TransactionsService,
            transactionService: TransactionService,
            walletService: WalletService,
            walletsService: WalletsService,
            explorerService: ExplorerService,
            scanService: ScanService,
            nftService: NFTService,
            avatarService: AvatarService,
            swapService: SwapService,
            appReleaseService: AppReleaseService,
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
            eventManager: EventManager,
            viewModelFactory: ViewModelFactory,
            rewardsService: RewardsService
        ) {
            self.assetsService = assetsService
            self.balanceService = balanceService
            self.bannerService = bannerService
            self.chainServiceFactory = chainServiceFactory
            self.connectionsService = connectionsService
            self.deviceService = deviceService
            self.nodeService = nodeService
            self.notificationHandler = notificationHandler
            self.priceAlertService = priceAlertService
            self.priceService = priceService
            self.priceObserverService = priceObserverService
            self.stakeService = stakeService
            self.transactionsService = transactionsService
            self.transactionService = transactionService
            self.walletService = walletService
            self.walletsService = walletsService
            self.explorerService = explorerService
            self.scanService = scanService
            self.nftService = nftService
            self.avatarService = avatarService
            self.swapService = swapService
            self.appReleaseService = appReleaseService
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
            self.eventManager = eventManager
            self.viewModelFactory = viewModelFactory
            self.rewardsService = rewardsService
        }
    }
}
