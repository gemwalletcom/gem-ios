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

    @Published var isCurrencyScenePresented: Bool?
    @Published var isDeveloperEnabled: Bool {
        didSet { preferences.isDeveloperEnabled = isDeveloperEnabled }
    }

    private let wallet: Wallet
    private let walletService: WalletService
    private let preferences = Preferences.main
    private let keystore: any Keystore

    init(
        keystore: any Keystore,
        walletService: WalletService,
        wallet: Wallet,
        currencyModel: CurrencySceneViewModel,
        securityModel: SecurityViewModel
    ) {
        self.keystore = keystore
        self.walletService = walletService
        self.currencyModel = currencyModel
        self.securityModel = securityModel
        self.isDeveloperEnabled = preferences.isDeveloperEnabled
        self.wallet = wallet
    }

    var title: String { Localized.Settings.title }

    var walletsTitle: String { Localized.Wallets.title }
    var walletsValue: String { "\(keystore.wallets.count)" }
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
    // TODO: - Change an image there before merging to main
    var lanugageImage: Image { Image(.settingsNetworks) }

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

    var rateAppTitle: String { Localized.Settings.rateApp }
    var rateAppImage: Image { Image(.settingsRate) }

    var developerModeTitle: String { Localized.Settings.developer }
    var developerModeImage: Image { Image(.settingsDeveloper) }

    var versionTextTitle: String { Localized.Settings.version }
    var versionTextValue: String {
        let version = Bundle.main.releaseVersionNumber
        let number = Bundle.main.buildVersionNumber
        return "\(version) (\(number))"
    }
    var versionTextImage: Image { Image(.settingsVersion) }

    var contextCopyTitle: String { Localized.Common.copy }
    var contextDevTitle: String { Localized.Settings.enableValue(Localized.Settings.developer) }

}

// MARK: - Business Logic

extension SettingsViewModel {
    func fetch() async throws {
        try await walletService.changeCurrency(wallet: wallet)
    }
}
