// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct ChainsFilterViewModel: ChainsFilterable {
    var allChains: [Primitives.Chain]
    var selectedChains: [Primitives.Chain]
    var typeModel: ChainsFilterTypeViewModel {
        ChainsFilterTypeViewModel(
            type: ChainsFilterType(selectedChains: selectedChains)
        )
    }
}

