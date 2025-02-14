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
import ManageWalletService
import AvatarService

extension EnvironmentValues {
    @Entry var navigationState: NavigationStateManager = .main
    @Entry var keystore: any Keystore = LocalKeystore.main
    @Entry var nodeService: NodeService = .main
    @Entry var priceService: PriceService = .main
    @Entry var explorerService: ExplorerService = .standard
    @Entry var walletsService: WalletsService = .main
    @Entry var manageWalletService: ManageWalletService = .main
    @Entry var priceAlertService: PriceAlertService = .main
    @Entry var deviceService: DeviceService = .main
    @Entry var balanceService: BalanceService = .main
    @Entry var bannerService: BannerService = .main
    @Entry var transactionsService: TransactionsService = .main
    @Entry var assetsService: AssetsService = .main
    @Entry var notificationService: NotificationService = .main
    @Entry var stakeService: StakeService = .main
    @Entry var connectionsService: ConnectionsService = .main
    @Entry var chainServiceFactory: ChainServiceFactory = .main
    @Entry var nftService: NFTService = .main
    @Entry var avatarService: AvatarService = .main
}
