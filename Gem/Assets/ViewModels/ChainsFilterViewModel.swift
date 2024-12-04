// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct ChainsFilterViewModel: Equatable {
    let allChains: [Primitives.Chain]
    var selectedChains: [Primitives.Chain]

    init(chains: [Primitives.Chain]) {
        self.allChains = chains
        self.selectedChains = []
    }

    var typeModel: ChainsFilterTypeViewModel {
        ChainsFilterTypeViewModel(
            type: ChainsFilterType(selectedChains: selectedChains)
        )
    }

    var isAnySelected: Bool { !selectedChains.isEmpty }
    var isEmpty: Bool { allChains.isEmpty }
}

