// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

protocol ChainsFilterable: Equatable {
    var allChains: [Chain] { get set }
    var typeModel: ChainsFilterTypeViewModel { get }
    var selectedChains: [Chain] { get set }

    var isAnySelected: Bool { get }
    var isEmpty: Bool { get }
}

extension ChainsFilterable {
    var isAnySelected: Bool { !selectedChains.isEmpty }
    var isEmpty: Bool { allChains.isEmpty }
}
