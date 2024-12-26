// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDB
import Store
import Keystore
import GemstonePrimitives
import BannerService
import NotificationService
import DeviceService
import PriceAlertService
import GemAPI
import ChainService
import StakeService
import NodeService

extension EnvironmentValues {
    @Entry var navigationState: NavigationStateManager = .main
    @Entry var keystore: any Keystore = LocalKeystore.main
    @Entry var nodeService: NodeService = .main
    @Entry var priceService: PriceService = .main
    @Entry var explorerService: ExplorerService = .main
    @Entry var walletsService: WalletsService = .main
    @Entry var walletService: WalletService = .main
    @Entry var priceAlertService: PriceAlertService = .main
    @Entry var subscriptionService: SubscriptionService = .main
    @Entry var deviceService: DeviceService = .main
    @Entry var balanceService: BalanceService = .main
    @Entry var bannerService: BannerService = .main
    @Entry var transactionsService: TransactionsService = .main
    @Entry var assetsService: AssetsService = .main
    @Entry var notificationService: NotificationService = .main
    @Entry var stakeService: StakeService = .main
    @Entry var connectionsService: ConnectionsService = .main
    @Entry var isWalletsPresented: Binding<Bool> = .constant(false)
    @Entry var chainServiceFactory: ChainServiceFactory = .main
}
