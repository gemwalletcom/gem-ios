// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import enum Gemstone.SwapperError
import Formatters
import Localization
import Primitives

extension Gemstone.SwapperError: @retroactive RetryableError {
    public var isRetryAvailable: Bool {
        switch self {
        case .NoQuoteAvailable, .ComputeQuoteError, .TransactionError, .NetworkError: true
        case .NotSupportedChain, .NotSupportedAsset, .NotSupportedPair, .NoAvailableProvider,
             .InvalidAddress, .InvalidAmount, .InputAmountTooSmall, .InvalidRoute,
             .AbiError, .NotImplemented: false
        }
    }

    public func message(asset: Asset) -> String {
        switch self {
        case .InvalidAmount(let minAmount):
            if let value = BigInt(minAmount), !value.isZero {
                let value = ValueFormatter(style: .full).string(value, decimals: asset.decimals.asInt, currency: asset.symbol)
                return Localized.Errors.Swap.minimumAmount(value.boldMarkdown())
            }
            return Localized.Errors.Swap.amountTooSmall
        case .InputAmountTooSmall:
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
