// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Settings
import Style
import Primitives
import Store

struct SettingsScene: View {
    
    @ObservedObject var model: SettingsViewModel
    
    @Environment(\.isWalletsPresented) private var isWalletsPresented

    var onChange: VoidAction = .none
    
    init(
        model: SettingsViewModel,
        onChange: VoidAction = .none
    ) {
        self.model = model
        self.onChange = onChange
    }
    
    var body: some View {
        List {
            Section {
//                NavigationLink(value: Scenes.Wallets()) {
//                    ListItemView(title: Localized.Wallets.title, subtitle: model.walletsText, image: Image(.settingsWallets))
//                }
                NavigationCustomLink(with: ListItemView(title: Localized.Wallets.title, subtitle: model.walletsText, image: Image(.settingsWallets))) {
                    self.isWalletsPresented.wrappedValue = true
                }
                NavigationLink(value: Scenes.Security()) {
                    ListItemView(title: Localized.Settings.security, subtitle: .none, image: Image(.settingsSecurity))
                }
            }
            .id(TabScrollToTopId.settings)

            Section {
                NavigationLink(value: Scenes.Notifications()) {
                    ListItemView(title: Localized.Settings.Notifications.title, image: Image(.settingsNotifications))
                }
                NavigationLink(value: Scenes.Currency()) {
                    ListItemView(title: Localized.Settings.currency, subtitle: model.currencyValue, image: Image(.settingsCurrency))
                }
                NavigationLink(value: Scenes.Chains()) {
                    ListItemView(title: Localized.Settings.Networks.title, image: Image(.settingsNetworks))
                }
            }
            Section {
                NavigationLink(value: Scenes.WalletConnect()) {
                    ListItemView(title: Localized.WalletConnect.title, image: Image(.walletConnect))
                }
            }
            Section {
                ForEach(model.community) { item in
                    NavigationCustomLink(with: ListItemView(title: item.type.name, image: item.type.image)) {
                        UIApplication.shared.open(item.url)
                    }
                }
            } header: {
                Text(Localized.Settings.community)
            }
            Section {
                NavigationLink(value: Scenes.AboutUs()) {
                    ListItemView(title: Localized.Settings.aboutus, image: Image(.settingsGem))
                }
                NavigationCustomLink(with: ListItemView(title: Localized.Settings.rateApp, image: Image(.settingsRate))) {
                    RateService().rate()
                }
                if model.isDeveloperEnabled {
                    NavigationLink(value: Scenes.Developer()) {
                        ListItemView(title: Localized.Settings.developer, image: Image(.settingsDeveloper))
                    }
                }
                ListItemView(title: Localized.Settings.version, subtitle: model.versionText, image: Image(.settingsVersion))
                    .contextMenu {
                        ContextMenuCopy(title: Localized.Common.copy, value: model.versionText)
                        ContextMenuItem(title: Localized.Settings.enableValue(Localized.Settings.developer), image: SystemImage.info) {
                            model.isDeveloperEnabled.toggle()
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Localized.Settings.title)
        .onChange(of: model.currencyModel.currency) {
            self.onChange?()
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildVersionNumber: Int {
        return Int((infoDictionary?["CFBundleVersion"] as? String ?? "")) ?? 0
    }
}

//struct SettingsScene_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsScene(model: SettingsViewModel(keystore: .main))
//    }
//}
