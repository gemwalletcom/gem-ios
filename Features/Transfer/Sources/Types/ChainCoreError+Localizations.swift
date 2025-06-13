// Copyright (c). Gem Wallet. All rights reserved.

import Localization
import Blockchain
import SwiftUI

extension ChainCoreError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cantEstimateFee, .feeRateMissed: Localized.Errors.unableEstimateNetworkFee
        case .incorrectAmount: Localized.Errors.invalidAmount
        case .dustThreshold(let chain): Localized.Errors.dustThreshold(chain.asset.name)
        }
    }
}
