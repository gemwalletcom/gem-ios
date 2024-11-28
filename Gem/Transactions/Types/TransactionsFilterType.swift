// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum TransactionsFilterType {
    case allTypes
    case type(name: TransactionType)
    case types(selected: [TransactionType])

    init(selectedTypes: [TransactionType]) {
        switch selectedTypes.count {
        case 0: self = .allTypes
        case 1: self = .type(name: selectedTypes[0])
        default: self = .types(selected: selectedTypes)
        }
    }
}

extension TransactionsFilterType: Equatable { }
