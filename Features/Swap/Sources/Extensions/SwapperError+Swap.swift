// Copyright (c). Gem Wallet. All rights reserved.

import enum Gemstone.SwapperError
import Primitives

extension Gemstone.SwapperError: RetryableError {
    public var isRetryAvailable: Bool {
        switch self {
        case .NoQuoteAvailable, .NetworkError:
            return true
        case .NotSupportedChain, .NotSupportedAsset, .NotSupportedPair, .NoAvailableProvider,
             .InputAmountTooSmall, .InvalidAddress, .InvalidAmount, .AbiError,
             .NotImplemented, .ComputeQuoteError, .InvalidRoute, .TransactionError:
            return false
        }
    }
}