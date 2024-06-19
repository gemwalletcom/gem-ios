// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Keystore

struct MainTabView: View {
    let wallet: Wallet
    let walletModel: WalletSceneViewModel
    let keystore: LocalKeystore

    @Binding var navigationStateManager: NavigationStateManagable

    var body: some View {
        ScrollViewReader { proxy in
            TabView(selection: navigationStateManager.tabViewSelection) {
                walletTabItemView
                transactionsTabItemView
                settingTabItemView
            }
            .onChange(of: navigationStateManager.scrollToTop) { oldValue, newValue in
                if oldValue != newValue {
                    onPerofrmScroll(proxy: proxy)
                }
            }
        }
        .onChange(of: keystore.currentWallet) {
            navigationStateManager.selectedTab = .wallet
        }
    }
}

// MARK: - UI Components

extension MainTabView {
    private var walletTabItemView: some View {
        WalletNavigationStack(
            wallet: wallet,
            walletModel: walletModel,
            navigationPath: $navigationStateManager.walletNavigationPath
        )
        .tabItem {
            tabItem(
                title: Localized.Wallet.title,
                image: Image(.tabWallet)
            )
        }
        .tag(TabItem.wallet)
    }

    private var transactionsTabItemView: some View {
        TransactionsNavigationStack(
            wallet: wallet,
            navigationPath: $navigationStateManager.activityNavigationPath
        )
        .tabItem {
            tabItem(
                title: Localized.Activity.title,
                image: Image(.tabActivity)
            )
        }
        .tag(TabItem.activity)
    }

    private var settingTabItemView: some View {
        SettingsNavigationStack(
            wallet: wallet,
            navigationPath: $navigationStateManager.settingsNavigationPath,
            currencyModel: CurrencySceneViewModel(),
            securityModel: SecurityViewModel()
        )
        .tabItem {
            tabItem(
                title: Localized.Settings.title,
                image: Image(.tabSettings)
            )
        }
        .tag(TabItem.settings)
    }

    @ViewBuilder
    private func tabItem(
        title: String,
        image: Image
    ) -> Label<Text, Image> {
        Label(
            title: { Text(title) },
            icon: { image }
        )
    }
}

// MARK: - Actions

extension MainTabView {
    @MainActor
    private func onPerofrmScroll(proxy: ScrollViewProxy) {
        guard navigationStateManager.scrollToTop else { return }
        withAnimation {
            proxy.scrollTo(navigationStateManager.selectedTab, anchor: .top)
            navigationStateManager.scrollToTop = false
        }
    }
}

// MARK: - Previews

#Preview {
    @State var navigationStateManager: NavigationStateManagable = NavigationStateManager(initialSelecedTab: .wallet)
    return MainTabView(
        wallet: .main,
        walletModel: .init(assetsService: .main, walletService: .main),
        keystore: .main,
        navigationStateManager: $navigationStateManager)
}
