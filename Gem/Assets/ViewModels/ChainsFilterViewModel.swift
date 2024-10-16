// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization

struct ChainsFilterViewModel {
    let type: ChainsFilterType

    var value: String {
        switch type {
        case .allChains:
            Localized.Common.all
        case let .chain(chain):
            chain.rawValue.capitalized
        case let .chains(selected):
            "\(selected.count)"
        }
    }

    var title: String {
        Localized.Settings.Networks.title
    }
    
    var chainsImage: Image { Image(.settingsNetworks) }
}
