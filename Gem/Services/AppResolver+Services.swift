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
        let walletConnectorManager: WalletConnectorManager

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
            walletConnectorManager: WalletConnectorManager
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
            self.walletConnectorManager = walletConnectorManager
        }
    }
}
