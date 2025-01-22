// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct TransacionTypesFilterViewModel: Equatable {
    public let allTransactionsTypes: [TransactionType]
    public var selectedTypes: [TransactionType]

    public init(types: [TransactionType]) {
        self.allTransactionsTypes = types
        self.selectedTypes = []
    }

    public var typeModel: TransactionsFilterTypeViewModel {
        TransactionsFilterTypeViewModel(
            type: TransactionsFilterType(selectedTypes: selectedTypes)
        )
    }

    public var isAnySelected: Bool { !selectedTypes.isEmpty }
    public var isEmpty: Bool { allTransactionsTypes.isEmpty }
}

