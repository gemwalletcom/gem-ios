// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Currency
import Store
import PrimitivesComponents
import PriceAlerts
import WalletConnector
import Preferences
import MarketInsight
import Settings
import ChainSettings
import PriceService
import ManageWallets
import WalletService

struct SettingsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.deviceService) private var deviceService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.connectionsService) private var connectionsService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.walletService) private var walletService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.priceService) private var priceService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.observablePreferences) private var observablePreferences
    @Environment(\.releaseService) private var releaseService

    @State private var currencyModel: CurrencySceneViewModel
    @State private var walletsModel: WalletsSceneViewModel

    let walletId: WalletId

    init(
        walletId: WalletId,
        preferences: Preferences = .standard,
        priceService: PriceService,
        walletService: WalletService
    ) {
        self.walletId = walletId
        _currencyModel = State(
            initialValue: CurrencySceneViewModel(
                currencyStorage: preferences,
                priceService: priceService
            )
        )
        _walletsModel = State(
            initialValue: WalletsSceneViewModel(walletService: walletService)
        )
    }

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.settings },
            set: { navigationState.settings = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            SettingsScene(
                model: SettingsViewModel(
                    walletId: walletId,
                    walletsService: walletsService,
                    currencyModel: currencyModel,
                    observablePrefereces: observablePreferences
                ),
                isPresentingWallets: $walletsModel.isPresentingWallets
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.Security.self) { _ in
                SecurityScene(model: SecurityViewModel())
            }
            .navigationDestination(for: Scenes.Notifications.self) { _ in
                NotificationsScene(
                    model: NotificationsViewModel(
                        deviceService: deviceService,
                        bannerService: bannerService
                    )
                )
            }
            .navigationDestination(for: Scenes.PriceAlerts.self) { _ in
                PriceAlertsNavigationView(
                    model: PriceAlertsViewModel(priceAlertService: priceAlertService)
                )
            }
            .navigationDestination(for: Scenes.Price.self) { scene in
                ChartScene(
                    model: ChartsViewModel(
                        priceService: walletsService.priceService,
                        assetModel: AssetViewModel(asset: scene.asset)
                    )
                )
            }
            .navigationDestination(for: Scenes.Chains.self) { _ in
                ChainListSettingsScene()
            }
            .navigationDestination(for: Scenes.AboutUs.self) { _ in
                AboutUsScene(
                    model: AboutUsViewModel(
                        preferences: observablePreferences,
                        releaseService: releaseService
                    )
                )
            }
            .navigationDestination(for: Scenes.WalletConnect.self) { _ in
                ConnectionsScene(
                    model: ConnectionsViewModel(
                        service: connectionsService
                    )
                )
            }
            .navigationDestination(for: Scenes.Developer.self) { _ in
                DeveloperScene(model: DeveloperViewModel(
                    walletId: walletId,
                    transactionsService: transactionsService,
                    assetService: assetsService,
                    stakeService: stakeService,
                    bannerService: bannerService,
                    priceService: priceService
                ))
            }
            .navigationDestination(for: Scenes.Currency.self) { _ in
                CurrencyScene(model: currencyModel)
            }
            .navigationDestination(for: Scenes.ChainSettings.self) {
                ChainSettingsScene(
                    model: ChainSettingsViewModel(nodeService: nodeService, chain: $0.chain)
                )
            }
            .sheet(isPresented: $walletsModel.isPresentingWallets) {
                WalletsNavigationStack(
                    model: walletsModel,
                    isPresentingWallets: $walletsModel.isPresentingWallets
                )
            }
        }
        .onChange(of: currencyModel.selectedCurrencyValue) { _, _ in
            navigationState.settings.removeLast()
        }
    }
}

extension Preferences: @retroactive CurrencyStorable {}
