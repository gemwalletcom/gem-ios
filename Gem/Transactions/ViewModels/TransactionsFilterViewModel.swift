// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization

struct TransactionsFilterViewModel {
    var chainsFilter: any ChainsFilterable

    init(model: any ChainsFilterable) {
        self.chainsFilter = model
    }

    var isAnyFilterSpecified: Bool {
        chainsFilter.isAnySelected
    }

    var title: String { Localized.Filter.title }
    var clear: String { Localized.Filter.clear }
    var done: String { Localized.Common.done }
}

// MARK: - Models extensions

extension TransactionsRequestFilter {
    var associatedChains: [String] {
        if case let .chains(chains) = self {
            return chains
        }
        return []
    }
}
