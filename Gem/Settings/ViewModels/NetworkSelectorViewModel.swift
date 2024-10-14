// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct NetworkSelectorViewModel {
    var title: String { Localized.Settings.Networks.title }

    let isMultipleSelectionEnabled: Bool
    let chains: [Chain]

    var selectedChains: Set<Chain>

    init(chains: [Chain], selectedChains: [Chain], isMultipleSelectionEnabled: Bool) {
        self.isMultipleSelectionEnabled = isMultipleSelectionEnabled
        self.chains = chains
        self.selectedChains = Set(selectedChains)
    }

    var cancelButtonTitle: String {
        Localized.Common.cancel
    }

    var clearButtonTitle: String {
        Localized.Filter.clear
    }

    var doneButtonTitle: String {
        Localized.Common.done
    }
}

// MARK: - Business Logic

extension NetworkSelectorViewModel {
    mutating func toggle(chain: Chain) {
        if selectedChains.contains(chain) {
            selectedChains.remove(chain)
        } else {
            selectedChains.insert(chain)
        }
    }

    mutating func clean() {
        selectedChains = []
    }
}

// MARK: - ChainFilterable

extension NetworkSelectorViewModel: ChainFilterable { }
