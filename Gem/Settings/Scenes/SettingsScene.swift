// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Settings
import Style
import Primitives
import Store
import Keystore

struct SettingsScene: View {
    @Environment(\.isWalletsPresented) private var isWalletsPresented
    @Environment(\.openURL) private var openURL

    @ObservedObject private var model: SettingsViewModel

    private var onChange: VoidAction = .none

    init(
        model: SettingsViewModel,
        onChange: VoidAction = .none
    ) {
        self.model = model
        self.onChange = onChange
    }

    var body: some View {
        List {
            walletsSection
            deviceSection
            walletConnectSection
            communitySection
            aboutSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
        .onChange(of: model.currencyModel.currency) { _, _ in
            onChange?()
        }
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

            NavigationLink(value: Scenes.Currency()) {
                ListItemView(
                    title: model.currencyTitle,
                    subtitle: model.currencyValue,
                    image: model.currencyImage)
            }

            NavigationCustomLink(
                with: ListItemView(
                    title: model.lanugageTitle,
                    subtitle: model.lanugageValue,
                    image: model.lanugageImage),
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
            NavigationLink(value: Scenes.AboutUs()) {
                ListItemView(
                    title: model.aboutUsTitle,
                    image: model.aboutUsImage
                )
            }

            NavigationCustomLink(
                with: ListItemView(
                    title: model.rateAppTitle,
                    image: model.rateAppImage
                ),
                action: onSelectRateApp
            )

            if model.isDeveloperEnabled {
                NavigationLink(value: Scenes.Developer()) {
                    ListItemView(
                        title: model.developerModeTitle,
                        image: model.developerModeImage
                    )
                }
            }

            ListItemView(
                title: model.versionTextTitle,
                subtitle: model.versionTextValue,
                image: model.versionTextImage
            )
            .contextMenu {
                ContextMenuCopy(
                    title: model.contextCopyTitle,
                    value: model.versionTextValue
                )
                ContextMenuItem(
                    title: model.contextDevTitle,
                    image: SystemImage.info,
                    action: onEnableDevSettings
                )
            }
        }
    }
}

// MARK: - Actions

extension SettingsScene {
    @MainActor
    private func onEnableDevSettings() {
        model.isDeveloperEnabled.toggle()
    }

    @MainActor
    private func onSelectRateApp() {
        RateService().rate()
    }

    @MainActor
    private func onSelectCommutity(link: CommunityLink) {
        openURL(link.url)
    }

    @MainActor
    private func onSelectLanguages() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
    }

    @MainActor
    private func onOpenWallets() {
        isWalletsPresented.wrappedValue.toggle()
    }
}

// MARK: - Effects

extension SettingsScene {
    var value: String? {
        guard let code = Locale.current.language.languageCode?.identifier else {
            return nil
        }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized//localizedString(for: code)
    }

    private func onOpenURL(url: URL) {
        
    }
}

// MARK: - Previews

#Preview {
    let vm: SettingsViewModel = .init(keystore: LocalKeystore.main, currencyModel: .init(), securityModel: .init())
    return NavigationStack {
        SettingsScene(
            model: vm,
            onChange: .none
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Bundle extensions

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildVersionNumber: Int {
        return Int((infoDictionary?["CFBundleVersion"] as? String ?? "")) ?? 0
    }
}
