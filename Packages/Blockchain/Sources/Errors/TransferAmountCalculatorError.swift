// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public enum TransferAmountCalculatorError: LocalizedError {
    case insufficientBalance(Asset)
    case insufficientNetworkFee(Asset)
    case minimumAccountBalanceTooLow(Asset)
}
