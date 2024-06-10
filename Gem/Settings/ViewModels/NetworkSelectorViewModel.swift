// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct NetworkSelectorViewModel: ChainFilterable {
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
