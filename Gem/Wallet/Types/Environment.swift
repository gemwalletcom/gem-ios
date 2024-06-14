// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDB
import Store
import Keystore
import GemstonePrimitives

struct DatabaseQueueKey: EnvironmentKey {
    static var defaultValue: DB { DB.main }
}

struct NodeServiceKey: EnvironmentKey {
    static var defaultValue: NodeService { NodeService.main }
}

struct ExplorerServiceKey: EnvironmentKey {
    static var defaultValue: ExplorerService { ExplorerService.main }
}

struct KeystoreKey: EnvironmentKey {
    static var defaultValue: any Keystore { LocalKeystore.main }
}

struct WalletServiceKey: EnvironmentKey {
    static var defaultValue: WalletService { WalletService.main }
}

struct SubscriptionServiceKey: EnvironmentKey {
    static var defaultValue: SubscriptionService { SubscriptionService.main }
}

struct DeviceServiceKey: EnvironmentKey {
    static var defaultValue: DeviceService { DeviceService(subscriptionsService: .main, walletStore: .main) }
}

struct TransactionsServiceKey: EnvironmentKey {
    static var defaultValue: TransactionsService { TransactionsService.main }
}

struct AssetsServiceKey: EnvironmentKey {
    static var defaultValue: AssetsService { AssetsService.main }
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
    var db: DB {
        get { self[DatabaseQueueKey.self] }
        set { self[DatabaseQueueKey.self] = newValue }
    }
    
    var nodeService: NodeService {
        get { self[NodeServiceKey.self] }
        set { self[NodeServiceKey.self] = newValue }
    }
    
    var keystore: any Keystore {
        get { self[KeystoreKey.self] }
        set { self[KeystoreKey.self] = newValue }
    }
    
    var walletService: WalletService {
        get { self[WalletServiceKey.self] }
        set { self[WalletServiceKey.self] = newValue }
    }
    
    var subscriptionService: SubscriptionService {
        get { self[SubscriptionServiceKey.self] }
        set { self[SubscriptionServiceKey.self] = newValue }
    }
    
    var deviceService: DeviceService {
        get { self[DeviceServiceKey.self] }
        set { self[DeviceServiceKey.self] = newValue }
    }
    
    var transactionsService: TransactionsService {
        get { self[TransactionsServiceKey.self] }
        set { self[TransactionsServiceKey.self] = newValue }
    }
    
    var assetsService: AssetsService {
        get { self[AssetsServiceKey.self] }
        set { self[AssetsServiceKey.self] = newValue }
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
