// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct ChainsFilterViewModel: Equatable {
    public let allChains: [Primitives.Chain]
    public var selectedChains: [Primitives.Chain]

    public init(chains: [Primitives.Chain]) {
        self.allChains = chains
        self.selectedChains = []
    }

    public var typeModel: ChainsFilterTypeViewModel {
        ChainsFilterTypeViewModel(
            type: ChainsFilterType(selectedChains: selectedChains)
        )
    }

    public var isAnySelected: Bool { !selectedChains.isEmpty }
    public var isEmpty: Bool { allChains.isEmpty }
}

