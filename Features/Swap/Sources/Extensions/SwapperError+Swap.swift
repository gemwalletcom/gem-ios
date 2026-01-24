// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Formatters
import enum Gemstone.SwapperError
import Localization
import Primitives

extension Gemstone.SwapperError: @retroactive RetryableError {
    public var isRetryAvailable: Bool {
        switch self {
        case .NoQuoteAvailable, .ComputeQuoteError, .TransactionError: true
        case .NotSupportedChain, .NotSupportedAsset, .NoAvailableProvider,
             .InputAmountError, .InvalidRoute: false
        }
    }

    public func message(asset: Asset) -> String {
        switch self {
        case .InputAmountError(let minAmount):
            if let minAmount, let value = BigInt(minAmount), !value.isZero {
                let value = ValueFormatter(style: .full).string(value, decimals: asset.decimals.asInt, currency: asset.symbol)
                return Localized.Errors.Swap.minimumAmount(value.boldMarkdown())
            }
            return Localized.Errors.Swap.amountTooSmall
        default:
            return localizedDescription
        }
    }
}

extension Error {
    func asAnyError(asset: Asset?) -> any Error {
        guard let swapperError = self as? SwapperError, let asset else {
            return self
        }
        return AnyError(swapperError.message(asset: asset))
    }
}
