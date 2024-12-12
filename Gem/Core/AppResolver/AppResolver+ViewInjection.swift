// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store

extension View {
    func inject(resolver: AppResolver) -> some View {
        self
            .inject(stores: resolver.stores)
            .inject(services: resolver.services)
            .inject(stores: resolver.stores)
    }

    private func inject(services: AppResolver.Services) -> some View {
        self
            .environment(\.nodeService, services.nodeService)
            .environment(\.walletService, services.walletService)
            .environment(\.walletsService, services.walletsService)
            .environment(\.deviceService, services.deviceService)
            .environment(\.subscriptionService, services.subscriptionService)
            .environment(\.transactionsService, services.transactionsService)
            .environment(\.assetsService, services.assetsService)
            .environment(\.stakeService, services.stakeService)
            .environment(\.bannerService, services.bannerService)
            .environment(\.balanceService, services.balanceService)
            .environment(\.priceAlertService, services.priceAlertService)
            .environment(\.notificationService, services.notificationService)
            .environment(\.chainServiceFactory, services.chainServiceFactory)
            .environment(\.priceService, services.priceService)
            .environment(\.explorerService, services.explorerService)
            .environment(\.connectionsService, services.connectionsService)
    }

    private func inject(stores: AppResolver.Storages) -> some View {
        self
            .databaseContext(.readWrite { stores.db.dbQueue })
            .environment(\.keystore, stores.keystore)
            .environment(\.observablePreferences, stores.observablePreferences)
    }

    private func inject(navigation: NavigationStateManager) -> some View {
        self
            .environment(\.navigationState, navigation)
    }
}
