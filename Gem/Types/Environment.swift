// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDB
import Store
import Keystore
import BannerService
import NotificationService
import DeviceService
import PriceAlertService
import GemAPI
import ChainService
import StakeService
import NodeService
import PriceService
import WalletConnector
import ExplorerService
import NFTService
import BalanceService
import AssetsService
import TransactionsService
import WalletsService
import WalletService
import AvatarService
import AppService
import ScanService
import SwapService

extension EnvironmentValues {
    @Entry var navigationState: NavigationStateManager = AppResolver.main.navigation
    @Entry var keystore: any Keystore = AppResolver.main.storages.keystore
    @Entry var nodeService: NodeService = AppResolver.main.services.nodeService
    @Entry var priceService: PriceService = AppResolver.main.services.priceService
    @Entry var priceObserverService: PriceObserverService = AppResolver.main.services.priceObserverService
    @Entry var explorerService: ExplorerService = AppResolver.main.services.explorerService
    @Entry var walletsService: WalletsService = AppResolver.main.services.walletsService
    @Entry var walletService: WalletService = AppResolver.main.services.walletService
    @Entry var priceAlertService: PriceAlertService = AppResolver.main.services.priceAlertService
    @Entry var deviceService: DeviceService = AppResolver.main.services.deviceService
    @Entry var balanceService: BalanceService = AppResolver.main.services.balanceService
    @Entry var bannerService: BannerService = AppResolver.main.services.bannerService
    @Entry var transactionsService: TransactionsService =  AppResolver.main.services.transactionsService
    @Entry var assetsService: AssetsService = AppResolver.main.services.assetsService
    @Entry var notificationHandler: NotificationHandler =  AppResolver.main.services.notificationHandler
    @Entry var stakeService: StakeService = AppResolver.main.services.stakeService
    @Entry var connectionsService: ConnectionsService = AppResolver.main.services.connectionsService
    @Entry var chainServiceFactory: ChainServiceFactory = AppResolver.main.services.chainServiceFactory
    @Entry var nftService: NFTService = AppResolver.main.services.nftService
    @Entry var avatarService: AvatarService = AppResolver.main.services.avatarService
    @Entry var releaseService: AppReleaseService = AppResolver.main.services.appReleaseService
    @Entry var scanService: ScanService = AppResolver.main.services.scanService
    @Entry var swapService: SwapService = AppResolver.main.services.swapService
}
