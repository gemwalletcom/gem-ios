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

extension NavigationStateManager: EnvironmentKey {
    public static let defaultValue: NavigationStateManager = NavigationStateManager(initialSelecedTab: .wallet)
}

// TODO: - Enviroment key add as extensions

struct NodeServiceKey: EnvironmentKey {
    static var defaultValue: NodeService { NodeService.main }
}

struct PriceServiceKey: EnvironmentKey {
    static var defaultValue: PriceService { PriceService.main }
}

struct ExplorerServiceKey: EnvironmentKey {
    static var defaultValue: ExplorerService { ExplorerService.main }
}

struct KeystoreKey: EnvironmentKey {
    static var defaultValue: any Keystore { LocalKeystore.main }
}

struct WalletsServiceKey: EnvironmentKey {
    static var defaultValue: WalletsService { WalletsService.main }
}

extension PriceAlertService: @retroactive EnvironmentKey {
    public static let defaultValue: PriceAlertService = PriceAlertService.main
}

struct WalletServiceKey: EnvironmentKey {
    static var defaultValue: WalletService { WalletService.main }
}

extension SubscriptionService: @retroactive EnvironmentKey {
    public static let defaultValue: SubscriptionService = SubscriptionService(subscriptionProvider: GemAPIService.shared, walletStore: .main)
}

extension DeviceService: @retroactive EnvironmentKey {
    public static let defaultValue: DeviceService = DeviceService(deviceProvider: GemAPIService.shared, subscriptionsService: .main)
}

struct BalanceServiceKey: EnvironmentKey {
    static var defaultValue: BalanceService { BalanceService(
        balanceStore: .main,
        chainServiceFactory: ChainServiceFactory(nodeProvider: NodeService(nodeStore: .main)))
    }
}

extension BannerService: @retroactive EnvironmentKey {
    public static let defaultValue: BannerService = BannerService(store: .main, pushNotificationService: PushNotificationEnablerService(preferences: .main))
}

struct BannerSetupServiceKey: EnvironmentKey {
    static var defaultValue: BannerSetupService { BannerSetupService(store: .main, preferences: .main) }
}

struct TransactionsServiceKey: EnvironmentKey {
    static var defaultValue: TransactionsService { TransactionsService.main }
}

struct AssetsServiceKey: EnvironmentKey {
    static var defaultValue: AssetsService { AssetsService.main }
}

struct NotificationServiceKey: EnvironmentKey {
    static var defaultValue: NotificationService { NotificationService.main }
}

struct StakeServiceKey: EnvironmentKey {
    static var defaultValue: StakeService { StakeService.main }
}

struct ConnectionsServiceKey: EnvironmentKey {
    static var defaultValue: ConnectionsService { ConnectionsService.main }
}

struct ChainServiceFactoryKey: EnvironmentKey {
    static var defaultValue: ChainServiceFactory { ChainServiceFactory.init(nodeProvider: NodeService.main) }
}

struct IsWalletPresentedServiceKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> { .constant(false) }
}

extension EnvironmentValues {
    var nodeService: NodeService {
        get { self[NodeServiceKey.self] }
        set { self[NodeServiceKey.self] = newValue }
    }

    var priceService: PriceService {
        get { self[PriceServiceKey.self] }
        set { self[PriceServiceKey.self] = newValue }
    }

    var keystore: any Keystore {
        get { self[KeystoreKey.self] }
        set { self[KeystoreKey.self] = newValue }
    }

    var navigationState: NavigationStateManager {
        get { self[NavigationStateManager.self] }
        set { self[NavigationStateManager.self] = newValue }
    }

    var walletService: WalletService {
        get { self[WalletServiceKey.self] }
        set { self[WalletServiceKey.self] = newValue }
    }

    var walletsService: WalletsService {
        get { self[WalletsServiceKey.self] }
        set { self[WalletsServiceKey.self] = newValue }
    }

    var priceAlertService: PriceAlertService {
        get { self[PriceAlertService.self] }
        set { self[PriceAlertService.self] = newValue }
    }

    var subscriptionService: SubscriptionService {
        get { self[SubscriptionService.self] }
        set { self[SubscriptionService.self] = newValue }
    }
    
    var deviceService: DeviceService {
        get { self[DeviceService.self] }
        set { self[DeviceService.self] = newValue }
    }

    var balanceService: BalanceService {
        get { self[BalanceServiceKey.self] }
        set { self[BalanceServiceKey.self] = newValue }
    }

    var bannerService: BannerService {
        get { self[BannerService.self] }
        set { self[BannerService.self] = newValue }
    }

    var bannerSetupService: BannerSetupService {
        get { self[BannerSetupServiceKey.self] }
        set { self[BannerSetupServiceKey.self] = newValue }
    }

    var transactionsService: TransactionsService {
        get { self[TransactionsServiceKey.self] }
        set { self[TransactionsServiceKey.self] = newValue }
    }
    
    var assetsService: AssetsService {
        get { self[AssetsServiceKey.self] }
        set { self[AssetsServiceKey.self] = newValue }
    }

    var notificationService: NotificationService {
        get { self[NotificationServiceKey.self] }
        set { self[NotificationServiceKey.self] = newValue }
    }

    var stakeService: StakeService {
        get { self[StakeServiceKey.self] }
        set { self[StakeServiceKey.self] = newValue }
    }
    
    var connectionsService: ConnectionsService {
        get { self[ConnectionsServiceKey.self] }
        set { self[ConnectionsServiceKey.self] = newValue }
    }
    
    var explorerService: ExplorerService {
        get { self[ExplorerServiceKey.self] }
        set { self[ExplorerServiceKey.self] = newValue }
    }
    
    var isWalletsPresented: Binding<Bool> {
        get { self[IsWalletPresentedServiceKey.self] }
        set { self[IsWalletPresentedServiceKey.self] = newValue }
    }
    
    var chainServiceFactory: ChainServiceFactory {
        get { self[ChainServiceFactoryKey.self] }
        set { self[ChainServiceFactoryKey.self] = newValue }
    }
}
