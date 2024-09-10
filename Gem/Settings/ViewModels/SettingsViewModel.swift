// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Keystore
import GemstonePrimitives
import Gemstone
import Primitives

// TODO: - #1 think about to create some builder for List sections
// TODO: - #2 review observation migrate to @Observable
class SettingsViewModel: ObservableObject {
    @ObservedObject var currencyModel: CurrencySceneViewModel
    @ObservedObject var securityModel: SecurityViewModel

    @Published var isDeveloperEnabled: Bool

    private let walletId: WalletId
    private let walletsService: WalletsService
    private let preferences = Preferences.main

    init(
        walletId: WalletId,
        walletsService: WalletsService,
        currencyModel: CurrencySceneViewModel,
        securityModel: SecurityViewModel
    ) {
        self.walletId = walletId
        self.walletsService = walletsService
        self.currencyModel = currencyModel
        self.securityModel = securityModel
        self.isDeveloperEnabled = preferences.isDeveloperEnabled
    }

    var title: String { Localized.Settings.title }

    var walletsTitle: String { Localized.Wallets.title }
    var walletsValue: String { "\(walletsService.keystore.wallets.count)" }
    var walletsImage: Image { Image(.settingsWallets) }

    var securityTitle: String { Localized.Settings.security }
    var securityImage: Image { Image(.settingsSecurity) }

    var notificationsTitle: String { Localized.Settings.Notifications.title }
    var notificationsImage: Image { Image(.settingsNotifications) }

    var currencyTitle: String { Localized.Settings.currency }
    var currencyValue: String {
        let currentCurrency = currencyModel.currency

        if let currentFlag = currencyModel.emojiFlag {
            return "\(currentFlag) \(currentCurrency)"
        }
        return currentCurrency
    }
    var currencyImage: Image { Image(.settingsCurrency) }

    var lanugageTitle: String { Localized.Settings.language }
    var lanugageValue: String {
        guard let code = Locale.current.language.languageCode?.identifier else {
            return ""
        }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    var lanugageImage: Image { Image(.settingsLanguage) }

    var chainsTitle: String { Localized.Settings.Networks.title }
    var chainsImage: Image { Image(.settingsNetworks) }

    var walletConnectTitle: String { Localized.WalletConnect.title }
    var walletConnectImage: Image { Image(.walletConnect) }

    var commutinyTitle: String { Localized.Settings.community }
    var communityLinks: [CommunityLink] {
        let links: [SocialUrl] = [.x, .discord, .telegram, .gitHub, .youTube]

        return links.compactMap {
            if let url = Social.url($0) {
                return CommunityLink(type: $0, url: url)
            }
            return .none
        }
    }
    
    var aboutUsTitle: String { Localized.Settings.aboutus }
    var aboutUsImage: Image { Image(.settingsGem) }

    var helpCenterTitle: String { Localized.Settings.helpCenter }
    var helpCenterImage: Image { Image(.settingsHelpCenter) }

    var supportTitle: String { Localized.Settings.support }
    var supportImage: Image { Image(.settingsSupport) }

    var developerModeTitle: String { Localized.Settings.developer }
    var developerModeImage: Image { Image(.settingsDeveloper) }
}

// MARK: - Business Logic

extension SettingsViewModel {
    func fetch() async throws {
        try await walletsService.changeCurrency(walletId: walletId)
    }
}
