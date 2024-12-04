// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization

struct TransactionsFilterViewModel: Equatable {
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
            isMultiSelectionEnabled: true
        )
    }
    
    var requestFilters: [TransactionsRequestFilter] {
        var filters: [TransactionsRequestFilter] = []
        
        if !chainsFilter.selectedChains.isEmpty {
            let chainIds = chainsFilter.selectedChains.map { $0.rawValue }
            filters.append(.chains(chainIds))
        }
        
        if !transactionTypesFilter.selectedTypes.isEmpty {
            let typeIds = transactionTypesFilter.selectedTypes.map { $0.rawValue }
            filters.append(.types(typeIds))
        }
        
        return filters
    }
}

extension TransactionsFilterViewModel {
    init(wallet: Wallet) {
        self.init(
            chainsFilterModel: ChainsFilterViewModel(
                chains: wallet.chains(type: .all)
            ),
            transactionTypesFilter: TransacionTypesFilterViewModel(
                types: TransactionType.allCases
            )
        )
    }
}
