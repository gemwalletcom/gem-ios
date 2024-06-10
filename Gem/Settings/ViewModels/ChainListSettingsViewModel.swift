// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings

struct ChainListSettingsViewModel {
    var title: String {
        return Localized.Settings.Networks.title
    }
}

// MARK: - ChainFilterable

extension ChainListSettingsViewModel: ChainFilterable {
    var chains: [Chain] {
        AssetConfiguration.allChains
    }
}

