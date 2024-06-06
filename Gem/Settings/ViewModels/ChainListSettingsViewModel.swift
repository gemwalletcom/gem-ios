// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings

struct ChainListSettingsViewModel {
    
    var title: String {
        return Localized.Settings.Networks.title
    }

    var chains: [Chain] {
        return AssetConfiguration.allChains
    }

    func items(for searchText: String) -> [Chain] {
        guard !searchText.isEmpty else {
            return chains
        }
        return chains.filter {
            $0.asset.name.localizedCaseInsensitiveContains(searchText) ||
            $0.asset.symbol.localizedCaseInsensitiveContains(searchText) ||
            $0.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
}
