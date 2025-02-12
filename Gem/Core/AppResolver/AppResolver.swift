// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@MainActor
struct AppResolver {
    let storages: Storages
    let navigation: NavigationStateManager
    let services: Services

    init(
        storages: Storages = Storages(),
        factory: ServicesFactory = ServicesFactory(),
        navigation: NavigationStateManager = .main
    ) {
        self.storages = storages
        self.navigation = navigation
        self.services = factory.makeServices(storages: storages)
    }
}
