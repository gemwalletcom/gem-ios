// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GemstonePrimitives
import Gemstone
import Primitives
import Localization
import Style
import Currency
import Preferences
import WalletsService
import PrimitivesComponents
import Components

@Observable
@MainActor
public final class SettingsViewModel {
    var currencyModel: CurrencySceneViewModel

    private let walletId: WalletId
    private let walletsService: WalletsService
    private let observablePrefereces: ObservablePreferences

    public init(
        walletId: WalletId,
        walletsService: WalletsService,
        currencyModel: CurrencySceneViewModel,
        observablePrefereces: ObservablePreferences
    ) {
        self.walletId = walletId
        self.walletsService = walletsService
        self.currencyModel = currencyModel
        self.observablePrefereces = observablePrefereces
    }

    var isDeveloperEnabled: Bool {
        observablePrefereces.isDeveloperEnabled
    }

    var title: String { Localized.Settings.title }

    var walletsTitle: String { Localized.Wallets.title }
    var walletsValue: String {
        let count = (try? walletsService.walletsCount()) ?? .zero
        return "\(count)"
    }
    var walletsImage: AssetImage { AssetImage.image(Images.Settings.wallets) }

    var securityTitle: String { Localized.Settings.security }
    var securityImage: AssetImage { AssetImage.image(Images.Settings.security) }

    var notificationsTitle: String { Localized.Settings.Notifications.title }
    var notificationsImage: AssetImage { AssetImage.image(Images.Settings.notifications) }

    var priceAlertsTitle: String { Localized.Settings.PriceAlerts.title }
    var priceAlertsImage: AssetImage { AssetImage.image(Images.Settings.priceAlerts) }

    var currencyTitle: String { Localized.Settings.currency }
    var currencyValue: String { currencyModel.selectedCurrencyValue }
    var currencyImage: AssetImage { AssetImage.image(Images.Settings.currency) }

    var lanugageTitle: String { Localized.Settings.language }
    var lanugageValue: String {
        guard let code = Locale.current.language.languageCode?.identifier else {
            return ""
        }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    var lanugageImage: AssetImage { AssetImage.image(Images.Settings.language) }

    var chainsTitle: String { Localized.Settings.Networks.title }
    var chainsImage: AssetImage { AssetImage.image(Images.Settings.networks) }

    var walletConnectTitle: String { Localized.WalletConnect.title }
    var walletConnectImage: AssetImage { AssetImage.image(Images.Settings.walletConnect) }

    private let links: [SocialUrl] = [.x, .discord, .telegram, .gitHub, .youTube]
    var linksViewModel: SocialLinksViewModel {
        let assetLinks = links.compactMap {
            if let url = Social.url($0) {
                return AssetLink(
                    name: $0.linkType.rawValue,
                    url: url.absoluteString
                )
            }
            return .none
        }
        return SocialLinksViewModel(assetLinks: assetLinks)
    }
    
    var aboutUsTitle: String { Localized.Settings.aboutus }
    var aboutUsImage: AssetImage { AssetImage.image(Images.Settings.gem) }

    var helpCenterTitle: String { Localized.Settings.helpCenter }
    var helpCenterImage: AssetImage { AssetImage.image(Images.Settings.helpCenter) }
    var helpCenterURL: URL { Docs.url(.start) }

    var supportTitle: String { Localized.Settings.support }
    var supportImage: AssetImage { AssetImage.image(Images.Settings.support) }
    var supportURL: URL { PublicConstants.url(.support) }

    var developerModeTitle: String { Localized.Settings.developer }
    var developerModeImage: AssetImage { AssetImage.image(Images.Settings.developer) }
}

// MARK: - Business Logic

extension SettingsViewModel {
    func fetch() async throws {
        try await walletsService.changeCurrency(for: walletId)
    }
}
