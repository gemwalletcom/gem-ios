// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum BitcoinFeeCalculatorError: LocalizedError {
    case feeRateMissed
    case cantEstimateFee
    case incorrectAmount
}
