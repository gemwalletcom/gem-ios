// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct TransacionTypesFilterViewModel: Equatable {
    let allTransactionsTypes: [TransactionType]

    var selectedTypes: [TransactionType]

    init(types: [TransactionType]) {
        self.allTransactionsTypes = types
        self.selectedTypes = []
    }

    var typeModel: TransactionsFilterTypeViewModel {
        TransactionsFilterTypeViewModel(
            type: TransactionsFilterType(selectedTypes: selectedTypes)
        )
    }

    var isAnySelected: Bool { !selectedTypes.isEmpty }
    var isEmpty: Bool { allTransactionsTypes.isEmpty }
}

