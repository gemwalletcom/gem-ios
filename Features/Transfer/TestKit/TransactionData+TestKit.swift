// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@testable import Primitives

public extension TransactionData {
    static func mock() -> TransactionData {
        TransactionData(fee: Fee(fee: 1, gasPriceType: .regular(gasPrice: 1), gasLimit: 1))
    }
}