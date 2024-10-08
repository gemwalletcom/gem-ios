// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings

@Observable
class ChainListSettingsViewModel {
    var title: String {
        Localized.Settings.Networks.title
    }

    var selectedChain: Chain?
}

// MARK: - ChainFilterable

extension ChainListSettingsViewModel: ChainFilterable {
    var chains: [Chain] {
        AssetConfiguration.allChains
    }
}

