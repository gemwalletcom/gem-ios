// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Localization
import PrimitivesComponents

public struct SettingsScene: View {
    @Environment(\.openURL) private var openURL

    @State private var model: SettingsViewModel

    @Binding private var isPresentingWallets: Bool

    public init(
        model: SettingsViewModel,
        isPresentingWallets: Binding<Bool>
    ) {
        _model = State(initialValue: model)
        _isPresentingWallets = isPresentingWallets
    }

    public var body: some View {
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
            NavigationLink(value: Scenes.Contacts()) {
                ListItemView(
                    title: model.contactsTitle,
                    image: model.contactsImage
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
        Section(Localized.Settings.community) {
            SocialLinksView(model: model.linksViewModel)
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
