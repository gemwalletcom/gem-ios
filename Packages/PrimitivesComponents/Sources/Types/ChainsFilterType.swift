// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum ChainsFilterType {
    case allChains
    case chain(name: Chain)
    case chains(selected: [Chain])

    public init(selectedChains: [Chain]) {
        switch selectedChains.count {
        case 0: self = .allChains
        case 1: self = .chain(name: selectedChains[0])
        default: self = .chains(selected: selectedChains)
        }
    }
}
