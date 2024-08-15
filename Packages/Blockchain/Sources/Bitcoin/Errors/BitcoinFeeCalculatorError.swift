// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum BitcoinFeeCalculatorError: Error {
    case feeRateMissed
    case cantEstimateFee
    case incorrectAmount
}
