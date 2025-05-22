// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import Localization

public enum TransferAmountCalculatorError: Equatable {
    case insufficientBalance(Asset)
    case insufficientNetworkFee(Asset)
    case minimumAccountBalanceTooLow(Asset, required: BigInt)
}

extension TransferAmountCalculatorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .insufficientBalance(let asset):
            Localized.Transfer.insufficientBalance(AssetViewModel(asset: asset).title)
        case .insufficientNetworkFee(let asset):
            Localized.Transfer.insufficientNetworkFeeBalance(AssetViewModel(asset: asset).title)
        case .minimumAccountBalanceTooLow(let asset, _):
            Localized.Transfer.minimumAccountBalance(AssetViewModel(asset: asset).title)
        }
    }
}
