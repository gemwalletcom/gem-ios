// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Keystore
import GRDB
import GRDBQuery
import Store
import Localization
import Style
import Currency
import NFT
import TransactionsService

struct MainTabView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.balanceService) private var balanceService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.notificationService) private var notificationService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.navigationState) private var navigationState
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    @Environment(\.observablePreferences) private var observablePreferences

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
                    walletsService: walletsService,
                    bannerService: bannerService,
                    observablePreferences: observablePreferences,
                    keystore: keystore
                )
            )
            .tabItem {
                tabItem(Localized.Wallet.title, Images.Tabs.wallet)
            }
            .tag(TabItem.wallet)
            
            if model.isCollectionsEnabled {
                CollectionsNavigationStack(
                    model: .init(
                        wallet: model.wallet,
                        sceneStep: .collections,
                        nftService: nftService,
                        deviceService: deviceService
                    )
                )
                .tabItem {
                    tabItem(Localized.Nft.collections, Images.Tabs.collections)
                }
                .tag(TabItem.collections)
            }
            
            TransactionsNavigationStack(
                model: .init(
                    wallet: model.wallet,
                    type: .all,
                    service: transactionsService
                )
            )
            .tabItem {
                tabItem(Localized.Activity.title, Images.Tabs.activity)
            }
            .badge(transactions)
            .tag(TabItem.activity)

            SettingsNavigationStack(
                walletId: model.wallet.walletId
            )
            .tabItem {
                tabItem(Localized.Settings.title, Images.Tabs.settings)
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
            Task {
                await onReceiveNotification(notification: notification)
            }
        }
        notificationService.clear()
    }

    private func onReceiveNotification(notification: PushNotification) async {
        do {
            switch notification {
            case .transaction(let walletIndex, let assetId):
                //select wallet
                if walletIndex != keystore.currentWallet?.index.asInt  {
                    keystore.setCurrentWalletIndex(walletIndex)
                }

                let asset = try await walletsService.assetsService.getOrFetchAsset(for: assetId)
                navigationState.wallet.append(Scenes.Asset(asset: asset))
            case .priceAlert(let assetId):
                let asset = try await walletsService.assetsService.getOrFetchAsset(for: assetId)
                navigationState.wallet.append(Scenes.Price(asset: asset))
            case .asset(let assetId), .buyAsset(let assetId):
                let asset = try await walletsService.assetsService.getOrFetchAsset(for: assetId)
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
        case .transaction, .asset, .priceAlert, .buyAsset, .swapAsset: .wallet
        case .test, .unknown: nil
        }
    }
}

// MARK: - Previews

#Preview {
    return MainTabView(model: MainTabViewModel(wallet: .main))
}
