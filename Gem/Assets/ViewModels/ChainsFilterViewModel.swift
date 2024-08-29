// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct ChainsFilterViewModel {
    let type: ChainsFilterType

    var title: String {
        switch type {
        case .allChains:
            Localized.Filter.allNetworks
        case let .chain(chain):
            chain.rawValue.capitalized
        case let .chains(selected):
            Localized.Filter.countNetworks(selected.count)
        }
    }
}
