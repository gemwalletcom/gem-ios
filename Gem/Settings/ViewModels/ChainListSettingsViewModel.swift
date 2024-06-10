// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings

struct ChainListSettingsViewModel {
    var chains: [Chain] = AssetConfiguration.allChains

    var title: String {
        return Localized.Settings.Networks.title
    }

    func filter(_ chain: Chain, query: String) -> Bool {
        chain.asset.name.localizedCaseInsensitiveContains(query) ||
        chain.asset.symbol.localizedCaseInsensitiveContains(query) ||
        chain.rawValue.localizedCaseInsensitiveContains(query)
    }
}
