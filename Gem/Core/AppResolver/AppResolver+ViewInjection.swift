// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

extension View {
    func inject(resolver: AppResolver) -> some View {
        self
            .inject(storages: resolver.storages)
            .inject(services: resolver.services)
            .inject(navigation: resolver.navigation)
    }

    private func inject(services: AppResolver.Services) -> some View {
        self
            .environment(\.nodeService, services.nodeService)
            .environment(\.walletService, services.walletService)
            .environment(\.walletsService, services.walletsService)
            .environment(\.deviceService, services.deviceService)
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

    private func inject(storages: AppResolver.Storages) -> some View {
        self
            .databaseContext(.readWrite { storages.db.dbQueue })
            .environment(\.keystore, storages.keystore)
            .environment(\.observablePreferences, storages.observablePreferences)
    }

    private func inject(navigation: NavigationStateManager) -> some View {
        self
            .environment(\.navigationState, navigation)
    }
}
