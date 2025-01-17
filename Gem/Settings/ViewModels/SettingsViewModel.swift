// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Keystore
import GemstonePrimitives
import Gemstone
import Primitives
import Localization
import Style
import MarketInsight
import Currency
import Preferences

// TODO: - #1 think about to create some builder for List sections
// TODO: - #2 review observation migrate to @Observable
class SettingsViewModel: ObservableObject {
    var currencyModel: CurrencySceneViewModel

    @Published var isDeveloperEnabled: Bool

    private let walletId: WalletId
    private let walletsService: WalletsService
    private let preferences = Preferences.standard

    init(
        walletId: WalletId,
        walletsService: WalletsService,
        currencyModel: CurrencySceneViewModel
    ) {
        self.walletId = walletId
        self.walletsService = walletsService
        self.currencyModel = currencyModel
        self.isDeveloperEnabled = preferences.isDeveloperEnabled
    }

    var title: String { Localized.Settings.title }

    var walletsTitle: String { Localized.Wallets.title }
    var walletsValue: String { "\(walletsService.keystore.wallets.count)" }
    var walletsImage: Image { Images.Settings.wallets }

    var securityTitle: String { Localized.Settings.security }
    var securityImage: Image { Images.Settings.security }

    var notificationsTitle: String { Localized.Settings.Notifications.title }
    var notificationsImage: Image { Images.Settings.notifications }

    var priceAlertsTitle: String { Localized.Settings.PriceAlerts.title }
    var priceAlertsImage: Image { Images.Settings.priceAlerts }

    var currencyTitle: String { Localized.Settings.currency }
    var currencyValue: String { currencyModel.selectedCurrencyValue }
    var currencyImage: Image { Images.Settings.currency }

    var lanugageTitle: String { Localized.Settings.language }
    var lanugageValue: String {
        guard let code = Locale.current.language.languageCode?.identifier else {
            return ""
        }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    var lanugageImage: Image { Images.Settings.language }

    var chainsTitle: String { Localized.Settings.Networks.title }
    var chainsImage: Image { Images.Settings.networks }

    var walletConnectTitle: String { Localized.WalletConnect.title }
    var walletConnectImage: Image { Images.Settings.walletConnect }

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
    var aboutUsImage: Image { Images.Settings.gem }

    var helpCenterTitle: String { Localized.Settings.helpCenter }
    var helpCenterImage: Image { Images.Settings.helpCenter }
    var helpCenterURL: URL { Docs.url(.start) }

    var supportTitle: String { Localized.Settings.support }
    var supportImage: Image { Images.Settings.support }
    var supportURL: URL { PublicConstants.url(.support) }

    var developerModeTitle: String { Localized.Settings.developer }
    var developerModeImage: Image { Images.Settings.developer }
}

// MARK: - Business Logic

extension SettingsViewModel {
    func fetch() async throws {
        try await walletsService.changeCurrency(walletId: walletId)
    }
}
