// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GemstonePrimitives
import enum Gemstone.SocialUrl
import Primitives
import Localization
import Style
import Preferences
import WalletsService
import PrimitivesComponents
import Components

@Observable
@MainActor
public final class SettingsViewModel {
    private let walletId: WalletId
    private let walletsService: WalletsService
    private let observablePrefereces: ObservablePreferences

    public init(
        walletId: WalletId,
        walletsService: WalletsService,
        observablePrefereces: ObservablePreferences
    ) {
        self.walletId = walletId
        self.walletsService = walletsService
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

    var preferencesTitle: String { Localized.Settings.Preferences.title }
    var preferencesImage: AssetImage { AssetImage.image(Images.Settings.preferences) }

    var walletConnectTitle: String { Localized.WalletConnect.title }
    var walletConnectImage: AssetImage { AssetImage.image(Images.Settings.walletConnect) }

    var rewardsTitle: String { Localized.Rewards.title }
    var rewardsImage: AssetImage { AssetImage.image(Images.Settings.gem) }
    var showsRewards: Bool { walletsService.hasMulticoinWallet() }

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

    var contactsTitle: String { Localized.Contacts.title }
    var contactsImage: AssetImage { AssetImage.image(Images.Settings.contacts) }
}
