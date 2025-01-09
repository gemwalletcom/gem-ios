// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings
import Localization
import PrimitivesComponents

struct ChainListSettingsViewModel {
    var title: String {
        Localized.Settings.Networks.title
    }
}

// MARK: - ChainFilterable

extension ChainListSettingsViewModel: ChainFilterable {
    var chains: [Chain] {
        AssetConfiguration.allChains
    }
}

