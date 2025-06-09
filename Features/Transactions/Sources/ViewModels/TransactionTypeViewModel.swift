// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct TransactionTypeViewModel {
    private let type: FilterType

    init(type: FilterType) {
        self.type = type
    }

    var title: String {
        switch type {
        case .transfers: Localized.Transfer.title
        case .smartContract: Localized.Transfer.SmartContract.title
        case .swaps: Localized.Wallet.swap
        case .stake: Localized.Transfer.Stake.title
        case .others: Localized.Transfer.Other.title
        }
    }
}
