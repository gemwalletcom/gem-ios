// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings

enum ChainsFilterType {
    case allChains
    case chain(name: Chain)
    case chains(selected: [Chain])

    static let primary = ChainsFilterType.allChains

    init(selectedChains: [Chain]) {
        switch selectedChains.count {
        case 0: self = .allChains
        case 1: self = .chain(name: selectedChains[0])
        default: self = .chains(selected: selectedChains)
        }
    }
}

extension ChainsFilterType: Equatable { }
