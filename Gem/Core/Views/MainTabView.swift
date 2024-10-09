// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Keystore
import GRDB
import GRDBQuery
import Store

struct MainTabView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.balanceService) private var balanceService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.notificationService) private var notificationService
    @Environment(\.navigationState) private var navigationState

    let model: MainTabViewModel

    @Query<TransactionsCountRequest>
    private var transactions: Int

    private var tabViewSelection: Binding<TabItem> {
        return Binding(
            get: {
                navigationState.selectedTab
            },
            set: {
                onSelect(tab: $0)
            }
        )
    }

    init(model: MainTabViewModel) {
        self.model = model
        _transactions = Query(constant: model.transactionsCountRequest)
    }

    var body: some View {
        TabView(selection: tabViewSelection) {
            WalletNavigationStack(
                model: .init(
                    wallet: model.wallet,
                    balanceService: balanceService,
                    walletsService: walletsService
                )
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
                )
            )
            .tabItem {
                tabItem(Localized.Activity.title, Image(.tabActivity) )
            }
            .badge(transactions)
            .tag(TabItem.activity)

            SettingsNavigationStack(
                currencyModel: CurrencySceneViewModel(),
                walletId: model.wallet.walletId
            )
            .tabItem {
                tabItem(Localized.Settings.title, Image(.tabSettings))
            }
            .tag(TabItem.settings)
        }
        .onChange(of: keystore.currentWalletId, onWalletIdChange)
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
        navigationState.select(tab: tab)
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
                navigationState.wallet.append(Scenes.Asset(asset: asset))
            case .priceAlert(let assetId):
                let asset = try walletsService.assetsService.getAsset(for: assetId)
                navigationState.wallet.append(Scenes.Price(asset: asset))
            case .buyAsset(let assetId):
                let asset = try walletsService.assetsService.getAsset(for: assetId)
                navigationState.wallet.append(Scenes.Asset(asset: asset))
            case .swapAsset(_, _):
                //let fromAsset = try walletsService.assetsService.getAsset(for: fromAssetId)
                //let toAsset = try walletsService.assetsService.getAsset(for: toAssetId)
                //TODO:
                //navigationStateManager.wallet.append(Scenes.Asset(asset: fromAsset))
                break
            case .test, .unknown:
                break
            }

            if let selectTab = notification.selectTab {
                navigationState.selectedTab = selectTab
            }
        } catch {
            NSLog("onReceiveNotification error \(error)")
        }
    }

    private func onWalletIdChange() {
        navigationState.clearAll()
        navigationState.selectedTab = .wallet
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
    return MainTabView(model: MainTabViewModel(wallet: .main))
}
