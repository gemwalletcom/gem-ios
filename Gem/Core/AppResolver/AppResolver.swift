// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import DeviceService
import StakeService
import BannerService
import PriceAlertService
import Keystore
import GemAPI
import ChainService
import NotificationService
import GemstonePrimitives

struct AppResolver {
    let stores: Storages
    let navigation: NavigationStateManager
    let services: Services

    init(
        stores: Storages = Storages(),
        navigation: NavigationStateManager = .main
    ) {
        self.stores = stores
        self.navigation = navigation
        self.services = Services(stores: stores)
    }
}
