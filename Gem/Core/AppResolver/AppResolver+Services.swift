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
import ManageWalletService
import ContactService

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
        let transactionsService: TransactionsService
        let transactionService: TransactionService
        let manageWalletService: ManageWalletService
        let walletsService: WalletsService
        let explorerService: ExplorerService
        let contactService: ContactService
        
        let deviceObserverService: DeviceObserverService
        let onstartService: OnstartAsyncService
        let walletConnectorManager: WalletConnectorManager

        init(
            assetsService: AssetsService,
            balanceService: BalanceService,
            bannerService: BannerService,
            chainServiceFactory: ChainServiceFactory,
            connectionsService: ConnectionsService,
            deviceService: DeviceService,
            nodeService: NodeService,
            notificationService: NotificationService,
            priceAlertService: PriceAlertService,
            priceService: PriceService,
            stakeService: StakeService,
            transactionsService: TransactionsService,
            transactionService: TransactionService,
            manageWalletService: ManageWalletService,
            walletsService: WalletsService,
            explorerService: ExplorerService,
            deviceObserverService: DeviceObserverService,
            onstartService: OnstartAsyncService,
            walletConnectorManager: WalletConnectorManager,
            contactService: ContactService
        ) {
            self.assetsService = assetsService
            self.balanceService = balanceService
            self.bannerService = bannerService
            self.chainServiceFactory = chainServiceFactory
            self.connectionsService = connectionsService
            self.deviceService = deviceService
            self.nodeService = nodeService
            self.notificationService = notificationService
            self.priceAlertService = priceAlertService
            self.priceService = priceService
            self.stakeService = stakeService
            self.transactionsService = transactionsService
            self.transactionService = transactionService
            self.manageWalletService = manageWalletService
            self.walletsService = walletsService
            self.explorerService = explorerService
            self.deviceObserverService = deviceObserverService
            self.onstartService = onstartService
            self.walletConnectorManager = walletConnectorManager
            self.contactService = contactService
        }
    }
}
