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
            Group {
                walletsSection
                deviceSection
                walletConnectSection
                communitySection
                aboutSection
            }
            .listRowInsets(.assetListRowInsets)
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
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
                    imageStyle: .settings(assetImage: model.walletsImage)
                ),
                action: onOpenWallets
            )

            NavigationLink(value: Scenes.Security()) {
                ListItemView(
                    title: model.securityTitle,
                    imageStyle: .settings(assetImage: model.securityImage)
                )
            }
        }
    }

    private var deviceSection: some View {
        Section {
            NavigationLink(value: Scenes.Notifications()) {
                ListItemView(
                    title: model.notificationsTitle,
                    imageStyle: .settings(assetImage: model.notificationsImage)
                )
            }
            
            NavigationLink(value: Scenes.PriceAlerts()) {
                ListItemView(
                    title: model.priceAlertsTitle,
                    imageStyle: .settings(assetImage: model.priceAlertsImage)
                )
            }

            NavigationLink(value: Scenes.Currency()) {
                ListItemView(
                    title: Localized.Settings.currency,
                    subtitle: model.currencyValue,
                    imageStyle: .settings(assetImage: model.currencyImage)
                )
            }

            NavigationCustomLink(
                with: ListItemView(
                    title: model.lanugageTitle,
                    subtitle: model.lanugageValue,
                    imageStyle: .settings(assetImage: model.lanugageImage)
                ),
                action: onSelectLanguages
            )

            NavigationLink(value: Scenes.Chains()) {
                ListItemView(
                    title: model.chainsTitle,
                    imageStyle: .settings(assetImage: model.chainsImage)
                )
            }
        }
    }

    private var walletConnectSection: some View {
        Section {
            NavigationLink(value: Scenes.WalletConnect()) {
                ListItemView(
                    title: model.walletConnectTitle,
                    imageStyle: .settings(assetImage: model.walletConnectImage)
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
            SafariNavigationLink(url: model.helpCenterURL) {
                ListItemView(
                    title: model.helpCenterTitle,
                    imageStyle: .settings(assetImage: model.helpCenterImage)
                )
            }

            SafariNavigationLink(url: model.supportURL) {
                ListItemView(
                    title: model.supportTitle,
                    imageStyle: .settings(assetImage: model.supportImage)
                )
            }

            NavigationLink(value: Scenes.AboutUs()) {
                ListItemView(
                    title: model.aboutUsTitle,
                    imageStyle: .settings(assetImage: model.aboutUsImage)
                )
            }

            if model.isDeveloperEnabled {
                NavigationLink(value: Scenes.Developer()) {
                    ListItemView(
                        title: model.developerModeTitle,
                        imageStyle: .settings(assetImage: model.developerModeImage)
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
}
