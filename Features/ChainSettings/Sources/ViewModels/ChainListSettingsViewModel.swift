// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents
import GemstonePrimitives

public struct ChainListSettingsViewModel {
    public init() { }
    
    var title: String {
        Localized.Settings.Networks.title
    }
}

// MARK: - ChainFilterable

extension ChainListSettingsViewModel: ChainFilterable {
    public var chains: [Chain] {
        AssetConfiguration.allChains
            .sorted { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) }
    }
}

