// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization

struct TransactionsFilterViewModel {
    var chainsFilter: ChainsFilterViewModel
    var transactionTypesFilter: TransacionTypesFilterViewModel

    init(chainsFilterModel: ChainsFilterViewModel,
         transactionTypesFilter: TransacionTypesFilterViewModel) {
        self.chainsFilter = chainsFilterModel
        self.transactionTypesFilter = transactionTypesFilter
    }

    var isAnyFilterSpecified: Bool {
        chainsFilter.isAnySelected || transactionTypesFilter.isAnySelected
    }

    var title: String { Localized.Filter.title }
    var clear: String { Localized.Filter.clear }
    var done: String { Localized.Common.done }

    var showChainsFilter: Bool {
        chainsFilter.allChains.count > 1
    }

    var networksModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            items: chainsFilter.allChains,
            selectedItems: chainsFilter.selectedChains,
            isMultiSelectionEnabled: true
        )
    }

    var typesModel: TransactionTypesSelectorViewModel {
        TransactionTypesSelectorViewModel(
            items: transactionTypesFilter.allTransactionsTypes,
            selectedItems: transactionTypesFilter.selectedTypes,
            isMultiSelectionEnabled: true)
    }
}
