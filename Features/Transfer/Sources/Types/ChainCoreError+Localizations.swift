// Copyright (c). Gem Wallet. All rights reserved.

import Localization
import Blockchain
import SwiftUI

extension ChainCoreError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cantEstimateFee, .feeRateMissed: Localized.Errors.unableEstimateNetworkFee
        case .incorrectAmount: Localized.Errors.invalidAmount
        case .dustThreshold: "This amount is considered dust — the network fee is higher than the amount itself."
        }
    }
}
