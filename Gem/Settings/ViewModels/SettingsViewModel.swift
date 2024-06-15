// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Keystore
import GemstonePrimitives
import Gemstone

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

    var currencyValue: String {
        let currentCurrency = currencyModel.currency

        if let currentFlag = currencyModel.emojiFlag {
            return "\(currentFlag) \(currentCurrency)"
        }
        return currentCurrency
    }

    var versionText: String {
        return String(format: "%@ (%d)", Bundle.main.releaseVersionNumber, Bundle.main.buildVersionNumber)
    }
    
    var community: [CommunityLink] {
        let links: [SocialUrl] = [.x, .discord, .telegram, .gitHub, .youTube]
        
        return links.compactMap {
            if let url = Social.url($0) {
                return CommunityLink(type: $0, url: url)
            }
            return .none
        }
    }
}

