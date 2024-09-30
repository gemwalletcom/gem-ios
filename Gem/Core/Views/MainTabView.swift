// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Keystore
import GRDB
import GRDBQuery
import Store

struct MainTabView: View {

    let model: MainTabViewModel

    @Environment(\.keystore) private var keystore
    @Environment(\.balanceService) private var balanceService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.notificationService) private var notificationService

    // TODO: - remove @Binding and use @Bindable instead prior to iOS 17, back when apple do a fix
    // ref: - https://forums.swift.org/t/using-observation-in-a-protocol-throws-compiler-error/69090/6 if object explicity conforms protocol
    // inject a protocol, by now swift can't process it
    @Binding var navigationStateManager: NavigationStateManagable

    @Query<TransactionsCountRequest>
    private var transactions: Int

    private var tabViewSelection: Binding<TabItem> {
        return Binding(
            get: {
                navigationStateManager.selectedTab
            },
            set: {
                onSelect(tab: $0)
            }
        )
    }

    init(
        model: MainTabViewModel,
        navigationStateManager: Binding<NavigationStateManagable>
    ) {
        self.model = model
        _transactions = Query(constant: model.transactionsCountRequest)
        _navigationStateManager = navigationStateManager
    }

    var body: some View {
        TabView(selection: tabViewSelection) {
            WalletNavigationStack(
                model: .init(
                    wallet: model.wallet,
                    balanceService: balanceService,
                    walletsService: walletsService
                ),
                navigationPath: $navigationStateManager.wallet
            )
            .tabItem {
                tabItem(Localized.Wallet.title, Image(.tabWallet))
            }
            .tag(TabItem.wallet)

            TransactionsNavigationStack(
                model: .init(
                    walletId: model.walletId,
                    wallet: model.wallet,
                    type: .all,
                    service: transactionsService
                ),
                navigationPath: $navigationStateManager.activity
            )
            .tabItem {
                tabItem(Localized.Activity.title, Image(.tabActivity) )
            }
            .badge(transactions)
            .tag(TabItem.activity)

            SettingsNavigationStack(
                walletId: model.wallet.walletId,
                navigationPath: $navigationStateManager.settings,
                currencyModel: CurrencySceneViewModel()
            )
            .tabItem {
                tabItem(Localized.Settings.title, Image(.tabSettings))
            }
            .tag(TabItem.settings)
        }
        .onChange(of: keystore.currentWalletId) {
            navigationStateManager.selectedTab = .wallet
        }
        .onChange(of: notificationService.notifications) { _, newValue in
            onReceiveNotifications(newValue)
        }
        .onAppear {
            //Needed here because .onChange(of: notificationService.notifications) not trigger on cold start
            onReceiveNotifications(notificationService.notifications)
        }
    }
}

// MARK: - UI Components

extension MainTabView {
    @ViewBuilder
    private func tabItem(_ title: String, _ image: Image) -> Label<Text, Image> {
        Label(
            title: { Text(title) },
            icon: { image }
        )
    }
}

// MARK: - Actions

extension MainTabView {
    private func onSelect(tab: TabItem) {
        navigationStateManager.select(tab: tab)
    }

    private func onReceiveNotifications(_ notifications: [PushNotification]) {
        if let notification = notifications.first {
            onReceiveNotification(notification: notification)
        }
        notificationService.clear()
    }

    private func onReceiveNotification(notification: PushNotification) {
        do {
            switch notification {
            case .transaction(let walletIndex, let assetId):
                //select wallet
                if walletIndex != keystore.currentWallet?.index.asInt  {
                    keystore.setCurrentWalletIndex(walletIndex)
                }

                let asset = try walletsService.assetsService.getAsset(for: assetId)
                navigationStateManager.wallet.append(Scenes.Asset(asset: asset))
            case .priceAlert(let assetId):
                let asset = try walletsService.assetsService.getAsset(for: assetId)
                navigationStateManager.wallet.append(Scenes.Price(asset: asset))
            case .buyAsset(let assetId):
                let asset = try walletsService.assetsService.getAsset(for: assetId)
                navigationStateManager.wallet.append(Scenes.Asset(asset: asset))
            case .swapAsset(let fromAssetId, let toAssetId):
                //let fromAsset = try walletsService.assetsService.getAsset(for: fromAssetId)
                //let toAsset = try walletsService.assetsService.getAsset(for: toAssetId)
                //TODO:
                //navigationStateManager.wallet.append(Scenes.Asset(asset: fromAsset))
                break
            case .test, .unknown:
                break
            }

            if let selectTab = notification.selectTab {
                navigationStateManager.selectedTab = selectTab
            }
        } catch {
            NSLog("onReceiveNotification error \(error)")
        }
    }
}

extension PushNotification {
    var selectTab: TabItem? {
        switch self {
        case .transaction, .priceAlert, .buyAsset, .swapAsset: .wallet
        case .test, .unknown: nil
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var navigationStateManager: NavigationStateManagable = NavigationStateManager(initialSelecedTab: .wallet)
    return MainTabView(
        model: MainTabViewModel(wallet: .main),
        navigationStateManager: $navigationStateManager)
}
