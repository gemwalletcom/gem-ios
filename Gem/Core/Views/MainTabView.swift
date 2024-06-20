// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Keystore

struct MainTabView: View {
    let wallet: Wallet
    let walletModel: WalletSceneViewModel
    let keystore: LocalKeystore

    // TODO: - remove @Binding and use @Bindable instead prior to iOS 17, back when apple do a fix
    // ref: - https://forums.swift.org/t/using-observation-in-a-protocol-throws-compiler-error/69090/6 if object explicity conforms protocol
    // inject a protocol, by now swift can't process it
    @Binding var navigationStateManager: NavigationStateManagable

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

    var body: some View {
        TabView(selection: tabViewSelection) {
            walletTabItemView
            transactionsTabItemView
            settingTabItemView
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
            navigationPath: $navigationStateManager.wallet
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
            navigationPath: $navigationStateManager.activity
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
            navigationPath: $navigationStateManager.settings,
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
    private func onSelect(tab: TabItem) {
        navigationStateManager.select(tab: tab)
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
