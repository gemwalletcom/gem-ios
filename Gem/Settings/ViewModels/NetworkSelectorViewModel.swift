// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI

struct NetworkSelectorViewModel {
    let isMultiSelectionEnabled: Bool
    let chains: [Chain]

    var selectedChains: Set<Chain>

    init(chains: [Chain], selectedChains: [Chain], isMultiSelectionEnabled: Bool) {
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
        self.chains = chains
        self.selectedChains = Set(selectedChains)
    }

    init(chains: [Chain]) {
        self.init(chains: chains, selectedChains: [], isMultiSelectionEnabled: false)
    }

    var title: String { Localized.Settings.Networks.title }
    var cancelButtonTitle: String { Localized.Common.cancel }
    var clearButtonTitle: String { Localized.Filter.clear }
    var doneButtonTitle: String { Localized.Common.done }
    var noResultsTitle: String { Localized.Common.noResultsFound }

    var noResultsImage: Image { Image(systemName: SystemImage.searchNoResults) }
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
