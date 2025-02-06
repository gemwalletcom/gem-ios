// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization
import PrimitivesComponents

public struct TransactionsFilterViewModel: Equatable {
    public var chainsFilter: ChainsFilterViewModel
    public var transactionTypesFilter: TransacionTypesFilterViewModel

    public init(chainsFilterModel: ChainsFilterViewModel,
         transactionTypesFilter: TransacionTypesFilterViewModel) {
        self.chainsFilter = chainsFilterModel
        self.transactionTypesFilter = transactionTypesFilter
    }

    public var isAnyFilterSpecified: Bool {
        chainsFilter.isAnySelected || transactionTypesFilter.isAnySelected
    }

    public var title: String { Localized.Filter.title }
    public var clear: String { Localized.Filter.clear }
    public var done: String { Localized.Common.done }

    public var networksModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            items: chainsFilter.allChains,
            selectedItems: chainsFilter.selectedChains,
            isMultiSelectionEnabled: true
        )
    }

    public var typesModel: TransactionTypesSelectorViewModel {
        TransactionTypesSelectorViewModel(
            items: transactionTypesFilter.allTransactionsTypes,
            selectedItems: transactionTypesFilter.selectedTypes,
            isMultiSelectionEnabled: true
        )
    }
    
    public var requestFilters: [TransactionsRequestFilter] {
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
                chains: wallet.chains
            ),
            transactionTypesFilter: TransacionTypesFilterViewModel(
                types: TransactionType.allCases
            )
        )
    }
}
