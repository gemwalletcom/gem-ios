// Copyright (c). Gem Wallet. All rights reserved.

import ActivityService
import AddressNameService
import AppService
import AssetsService
import AvatarService
import BalanceService
import BannerService
import ChainService
import ConnectionsService
import DeviceService
import EarnServices
import EventPresenterService
import ExplorerService
import Foundation
import GemAPI
import GRDB
import Keystore
import NameService
import NFTService
import NodeService
import NotificationService
import PerpetualService
import PriceAlertService
import PriceService
import RewardsService
import ScanService
import StakeService
import Store
import Support
import SwapService
import SwiftUI
import TransactionsService
import TransactionStateService
import WalletConnector
import WalletService
import WalletsService

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
    @Entry var transactionsService: TransactionsService = AppResolver.main.services.transactionsService
    @Entry var assetsService: AssetsService = AppResolver.main.services.assetsService
    @Entry var navigationPresenter: NavigationPresenter = AppResolver.main.services.navigationPresenter
    @Entry var stakeService: StakeService = AppResolver.main.services.stakeService
    @Entry var connectionsService: ConnectionsService = AppResolver.main.services.connectionsService
    @Entry var walletConnectorManager: WalletConnectorManager = AppResolver.main.services.walletConnectorManager
    @Entry var chainServiceFactory: ChainServiceFactory = AppResolver.main.services.chainServiceFactory
    @Entry var nftService: NFTService = AppResolver.main.services.nftService
    @Entry var avatarService: AvatarService = AppResolver.main.services.avatarService
    @Entry var releaseService: AppReleaseService = AppResolver.main.services.appReleaseService
    @Entry var scanService: ScanService = AppResolver.main.services.scanService
    @Entry var swapService: SwapService = AppResolver.main.services.swapService
    @Entry var perpetualService: PerpetualService = AppResolver.main.services.perpetualService
    @Entry var hyperliquidObserverService: any PerpetualObservable<HyperliquidSubscription> = AppResolver.main.services.hyperliquidObserverService
    @Entry var transactionStateService: TransactionStateService = AppResolver.main.services.transactionStateService
    @Entry var nameService: NameService = AppResolver.main.services.nameService
    @Entry var addressNameService: AddressNameService = AppResolver.main.services.addressNameService
    @Entry var activityService: ActivityService = AppResolver.main.services.activityService
    @Entry var eventPresenterService: EventPresenterService = AppResolver.main.services.eventPresenterService
    @Entry var viewModelFactory: ViewModelFactory = AppResolver.main.services.viewModelFactory
    @Entry var rewardsService: RewardsService = AppResolver.main.services.rewardsService
    @Entry var walletSearchService: WalletSearchService = AppResolver.main.services.walletSearchService
    @Entry var assetSearchService: AssetSearchService = AppResolver.main.services.assetSearchService
    @Entry var inAppNotificationService: InAppNotificationService = AppResolver.main.services.inAppNotificationService
    @Entry var earnServices: EarnServices = AppResolver.main.services.earnServices
    @Entry var supportService: SupportService = AppResolver.main.services.supportService
}
