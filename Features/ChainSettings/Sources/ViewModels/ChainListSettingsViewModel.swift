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

    var emptyContent: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .search(type: .networks))
    }
}

// MARK: - ChainFilterable

extension ChainListSettingsViewModel: ChainFilterable {
    public var chains: [Chain] {
        AssetConfiguration.allChains.sortByRank()
    }
}

