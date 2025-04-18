// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public enum TransferAmountCalculatorError: LocalizedError, Equatable {
    case insufficientBalance(Asset)
    case insufficientNetworkFee(Asset)
    case minimumAccountBalanceTooLow(Asset)
}
