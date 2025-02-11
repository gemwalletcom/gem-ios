// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings
import Localization
import PrimitivesComponents
import GemstonePrimitives

struct ChainListSettingsViewModel {
    var title: String {
        Localized.Settings.Networks.title
    }
}

// MARK: - ChainFilterable

extension ChainListSettingsViewModel: ChainFilterable {
    var chains: [Chain] {
        AssetConfiguration.allChains
            .sorted { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) }
    }
}

