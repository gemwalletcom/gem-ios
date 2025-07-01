// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletsService
import Store
import StoreTestKit
import AssetsService
import AssetsServiceTestKit
import BalanceService
import BalanceServiceTestKit
import PriceService
import PriceServiceTestKit
import ChainService
import ChainServiceTestKit
import TransactionService
import TransactionServiceTestKit
import BannerService
import BannerServiceTestKit
import Preferences
import PreferencesTestKit
import DeviceService
import DeviceServiceTestKit

public extension WalletsService {
    static func mock(
        walletStore: WalletStore = .mock(),
        assetsService: AssetsService = .mock(),
        balanceService: BalanceService = .mock(),
        priceService: PriceService = .mock(),
        priceObserver: PriceObserverService = .mock(),
        transactionService: TransactionService = .mock(),
        bannerSetupService: BannerSetupService = .mock(),
        addressStatusService: AddressStatusService = .mock(),
        preferences: ObservablePreferences = .mock(),
        deviceSyncManager: DeviceSyncManager = .mock()
    ) -> WalletsService {
        WalletsService(
            walletStore: walletStore,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserver,
            transactionService: transactionService,
            bannerSetupService: bannerSetupService,
            addressStatusService: addressStatusService,
            preferences: preferences,
            deviceSyncManager: deviceSyncManager
        )
    }
}
