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
            Localized.Transfer.insufficientBalance(Self.title(asset: asset))
        case .insufficientNetworkFee(let asset):
            Localized.Transfer.insufficientNetworkFeeBalance(Self.title(asset: asset))
        case .minimumAccountBalanceTooLow(let asset, _):
            Localized.Transfer.minimumAccountBalance(Self.title(asset: asset))
        }
    }
    
    public var isInfoSupported: Bool {
        switch self {
        case .insufficientBalance: false
        case .minimumAccountBalanceTooLow: false // TODO: - integrate into gemstone, provide info - https://docs.gemwallet.com/faq/account-minimal-balance/
        case .insufficientNetworkFee: true
        }
    }

    static private func title(asset: Asset) -> String {
        String(format: "%@ (%@)", asset.name, asset.symbol)
    }
}
