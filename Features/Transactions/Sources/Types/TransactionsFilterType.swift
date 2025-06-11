// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum TransactionsFilterType {
    case allTypes
    case type(name: TransactionFilterType)
    case types(selected: [TransactionFilterType])

    public init(selectedTypes: [TransactionFilterType]) {
        switch selectedTypes.count {
        case 0: self = .allTypes
        case 1: self = .type(name: selectedTypes[0])
        default: self = .types(selected: selectedTypes)
        }
    }
}

extension TransactionsFilterType: Equatable { }
