// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct TransactionTypesFilterViewModel: Equatable {
    public let allTransactionsTypes: [FilterType]
    public var selectedTypes: [FilterType]

    public init(types: [TransactionType]) {
        self.allTransactionsTypes = types.map { FilterType(transactionType: $0) }.unique()
        self.selectedTypes = []
    }
    
    public var requestFilters: [TransactionType] {
        selectedTypes.map { $0.filters }.reduce([], +).unique()
    }

    public var typeModel: TransactionsFilterTypeViewModel {
        TransactionsFilterTypeViewModel(
            type: TransactionsFilterType(selectedTypes: selectedTypes)
        )
    }

    public var isAnySelected: Bool { !selectedTypes.isEmpty }
    public var isEmpty: Bool { allTransactionsTypes.isEmpty }
}

