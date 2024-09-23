// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct SettingsNavigationStack: View {
    let walletId: WalletId

    @State private var isWalletsPresented = false

    @Binding var navigationPath: NavigationPath

    @ObservedObject var currencyModel: CurrencySceneViewModel
    
    @Environment(\.deviceService) private var deviceService
    @Environment(\.subscriptionService) private var subscriptionService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.connectionsService) private var connectionsService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.priceService) private var priceService

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SettingsScene(
                model: SettingsViewModel(
                    walletId: walletId,
                    walletsService: walletsService,
                    currencyModel: currencyModel
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.Security.self) { _ in
                SecurityScene(model: SecurityViewModel())
            }
            .navigationDestination(for: Scenes.Notifications.self) { _ in
                NotificationsScene(
                    model: NotificationsViewModel(
                        deviceService: deviceService,
                        subscriptionService: subscriptionService
                    )
                )
            }
            .navigationDestination(for: Scenes.PriceAlerts.self) { _ in
                PriceAlertsNavigationView(
                    model: PriceAlertsViewModel(priceAlertService: priceAlertService, priceService: priceService)
                )
            }
            .navigationDestination(for: Scenes.Price.self) { scene in
                ChartScene(
                    model: ChartsViewModel(
                        priceService: walletsService.priceService,
                        assetsService: walletsService.assetsService,
                        assetModel: AssetViewModel(asset: scene.asset)
                    )
                )
            }
            .navigationDestination(for: Scenes.Chains.self) { _ in
                ChainListSettingsScene()
            }
            .navigationDestination(for: Scenes.AboutUs.self) { _ in
                AboutUsScene()
            }
            .navigationDestination(for: Scenes.WalletConnect.self) { _ in
                ConnectionsScene(model: ConnectionsViewModel(service: connectionsService))
            }
            .navigationDestination(for: Scenes.Developer.self) { _ in
                DeveloperScene(model: DeveloperViewModel(
                    transactionsService: transactionsService,
                    assetService: assetsService,
                    stakeService: stakeService,
                    bannerService: bannerService
                ))
            }
            .navigationDestination(for: Scenes.WalletConnections.self) { _ in
                ConnectionsScene(
                    model: ConnectionsViewModel(
                        service: connectionsService
                    )
                )
            }
            .navigationDestination(for: Scenes.Currency.self) { _ in
                CurrencyScene(model: currencyModel)
            }
            .sheet(isPresented: $isWalletsPresented) {
                WalletsNavigationStack()
            }
        }
        .onChange(of: currencyModel.currency) { oldValue, newValue in
            navigationPath.removeLast()
        }
        .environment(\.isWalletsPresented, $isWalletsPresented)
    }
}

//#Preview {
//    SettingsNavigationStack()
//}
