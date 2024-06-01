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
}
