// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Keystore

struct MainTabView: View {

    let model: MainTabViewModel

    @Environment(\.keystore) private var keystore
    @Environment(\.walletService) private var walletService
    @Environment(\.transactionsService) private var transactionsService

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
            WalletNavigationStack(
                model: .init(wallet: model.wallet, walletService: walletService),
                navigationPath: $navigationStateManager.wallet
            )
            .tabItem {
                tabItem(Localized.Wallet.title, Image(.tabWallet))
            }
            .tag(TabItem.wallet)

            TransactionsNavigationStack(
                model: .init(
                    walletId: model.walletId,
                    type: .all,
                    service: transactionsService
                ),
                navigationPath: $navigationStateManager.activity
            )
            .tabItem {
                tabItem(Localized.Activity.title, Image(.tabActivity) )
            }
            .tag(TabItem.activity)

            SettingsNavigationStack(
                walletId: model.wallet.walletId,
                navigationPath: $navigationStateManager.settings,
                currencyModel: CurrencySceneViewModel(),
                securityModel: SecurityViewModel()
            )
            .tabItem {
                tabItem(Localized.Settings.title, Image(.tabSettings))
            }
            .tag(TabItem.settings)
        }
        .onChange(of: keystore.currentWalletId) {
            navigationStateManager.selectedTab = .wallet
        }
    }
}

// MARK: - UI Components

extension MainTabView {
    @ViewBuilder
    private func tabItem(
        _ title: String,
        _ image: Image
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
        model: MainTabViewModel(wallet: .main),
        navigationStateManager: $navigationStateManager)
}
