// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct NetworkSelectorViewModel {
    var title: String {
        Localized.Settings.Networks.title
    }
    
    let chains: [Chain]
    let selectedChain: Chain

    init(chains: [Chain], selectedChain: Chain) {
        self.chains = chains
        self.selectedChain = selectedChain
    }
}

// MARK: - ChainFilterable

extension NetworkSelectorViewModel: ChainFilterable { }
