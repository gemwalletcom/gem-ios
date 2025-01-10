// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Settings
import Style
import Primitives
import Store
import Keystore
import Localization
import MarketInsight

struct SettingsScene: View {
    @Environment(\.openURL) private var openURL

    @ObservedObject private var model: SettingsViewModel
    @Binding private var isPresentingWallets: Bool

    init(
        model: SettingsViewModel,
        isPresentingWallets: Binding<Bool>
    ) {
        self.model = model
        _isPresentingWallets = isPresentingWallets
    }

    var body: some View {
        List {
            walletsSection
            deviceSection
            walletConnectSection
            communitySection
            aboutSection
        }
        .onChange(of: model.currencyValue, onCurrencyChange)
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}

// MARK: - UI Components

extension SettingsScene {
    private var walletsSection: some View {
        Section {
            NavigationCustomLink(
                with: ListItemView(
                    title: model.walletsTitle,
                    subtitle: model.walletsValue,
                    image: model.walletsImage),
                action: onOpenWallets)

            NavigationLink(value: Scenes.Security()) {
                ListItemView(
                    title: model.securityTitle,
                    image: model.securityImage
                )
            }
        }
    }

    private var deviceSection: some View {
        Section {
            NavigationLink(value: Scenes.Notifications()) {
                ListItemView(
                    title: model.notificationsTitle,
                    image: model.notificationsImage
                )
            }

            NavigationLink(value: Scenes.PriceAlerts()) {
                ListItemView(
                    title: model.priceAlertsTitle,
                    image: model.priceAlertsImage
                )
            }

            NavigationLink(value: Scenes.Currency()) {
                ListItemView(title: Localized.Settings.currency, subtitle: model.currencyValue, image: model.currencyImage)
            }

            NavigationCustomLink(
                with: ListItemView(
                    title: model.lanugageTitle,
                    subtitle: model.lanugageValue,
                    image: model.lanugageImage
                ),
                action: onSelectLanguages
            )

            NavigationLink(value: Scenes.Chains()) {
                ListItemView(
                    title: model.chainsTitle,
                    image: model.chainsImage
                )
            }
        }
    }

    private var walletConnectSection: some View {
        Section {
            NavigationLink(value: Scenes.WalletConnect()) {
                ListItemView(
                    title: model.walletConnectTitle,
                    image: model.walletConnectImage
                )
            }
        }
    }

    private var communitySection: some View {
        Section(model.commutinyTitle) {
            ForEach(model.communityLinks) { link in
                NavigationCustomLink(
                    with: ListItemView(
                        title: link.type.name,
                        image: link.type.image
                    ),
                    action: { onSelectCommutity(link: link) }
                )
            }
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationOpenLink(url: model.helpCenterURL, with: ListItemView(
                title: model.helpCenterTitle,
                image: model.helpCenterImage
            ))

            NavigationOpenLink(url: model.supportURL, with: ListItemView(
                title: model.supportTitle,
                image: model.supportImage
            ))

            NavigationLink(value: Scenes.AboutUs()) {
                ListItemView(
                    title: model.aboutUsTitle,
                    image: model.aboutUsImage
                )
            }

            if model.isDeveloperEnabled {
                NavigationLink(value: Scenes.Developer()) {
                    ListItemView(
                        title: model.developerModeTitle,
                        image: model.developerModeImage
                    )
                }
            }
        }
    }
}

// MARK: - Actions

extension SettingsScene {
    private func onSelectCommutity(link: CommunityLink) {
        openURL(link.url)
    }

    private func onSelectLanguages() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
    }

    private func onOpenWallets() {
        isPresentingWallets.toggle()
    }

    private func onCurrencyChange() {
        Task {
            try await model.fetch()
        }
    }
}

// MARK: - Previews

#Preview {
   let model: SettingsViewModel = .init(
       walletId: .main,
       walletsService: .main,
       currencyModel: .init(currencyStorage: Preferences.main)
   )
    NavigationStack {
       SettingsScene(
        model: model, isPresentingWallets: .constant(false)
       )
       .navigationBarTitleDisplayMode(.inline)
   }
}

