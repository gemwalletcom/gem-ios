// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct TransactionTypesFilterViewModel: Equatable {
    public let allTransactionsTypes: [TransactionFilterType]
    public var selectedTypes: [TransactionFilterType]

    public init(types: [TransactionType]) {
        self.allTransactionsTypes = types.map { TransactionFilterType(transactionType: $0) }.unique().sorted()
        self.selectedTypes = []
    }
    
    public var requestFilters: [TransactionType] {
        selectedTypes.map { TransactionFilterTypeViewModel(type: $0).filters }.reduce([], +)
    }

    public var typeModel: TransactionsFilterTypeViewModel {
        TransactionsFilterTypeViewModel(
            type: TransactionsFilterType(selectedTypes: selectedTypes)
        )
    }

    public var isAnySelected: Bool { !selectedTypes.isEmpty }
    public var isEmpty: Bool { allTransactionsTypes.isEmpty }
}

