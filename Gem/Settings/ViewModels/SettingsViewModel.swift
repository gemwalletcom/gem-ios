// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Keystore
import GemstoneSwift

struct CommunityLink {
    let name: String
    let image: Image?
    let url: URL
}

extension CommunityLink: Identifiable {
    var id: String { name }
}

class SettingsViewModel: ObservableObject {
    
    let preferences = Preferences.main
    let keystore: any Keystore
    @ObservedObject var currencyModel: CurrencySceneViewModel
    @ObservedObject var securityModel: SecurityViewModel
    
    @Published var isDeveloperEnabled: Bool {
        didSet { preferences.isDeveloperEnabled = isDeveloperEnabled }
    }
    
    init(
        keystore: any Keystore,
        currencyModel: CurrencySceneViewModel,
        securityModel: SecurityViewModel
    ) {
        self.keystore = keystore
        self.currencyModel = currencyModel
        self.securityModel = securityModel
        self.isDeveloperEnabled = preferences.isDeveloperEnabled
    }
    
    var walletsText: String {
        "\(keystore.wallets.count)"
    }
    
    var versionText: String {
        return String(format: "%@ (%d)", Bundle.main.releaseVersionNumber, Bundle.main.buildVersionNumber)
    }
    
    var community: [CommunityLink] {
        return [
            CommunityLink(
                name: "X",
                image: Image(.x),
                url: Social.url(.x)
            ),
            CommunityLink(
                name: "Discord",
                image: Image(.discord),
                url: Social.url(.discord)
            ),
            CommunityLink(
                name: "Reddit",
                image: Image(.reddit),
                url: Social.url(.reddit)
            ),
            CommunityLink(
                name: "Telegram",
                image: Image(.telegram),
                url: Social.url(.telegram)
            ),
            CommunityLink(
                name: "Github",
                image: Image(.github),
                url: Social.url(.gitHub)
            ),
            CommunityLink(
                name: "YouTube",
                image: Image(.youtube),
                url: Social.url(.youTube)
            )
        ]
    }
}
