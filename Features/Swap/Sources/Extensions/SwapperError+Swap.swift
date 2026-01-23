// Copyright (c). Gem Wallet. All rights reserved.

import enum Gemstone.SwapperError
import Primitives

extension Gemstone.SwapperError: @retroactive RetryableError {
    public var isRetryAvailable: Bool {
        switch self {
        case .NoQuoteAvailable, .NetworkError, .ComputeQuoteError, .TransactionError: true
        case .NotSupportedChain, .NotSupportedAsset, .NotSupportedPair, .NoAvailableProvider,
             .InputAmountTooSmall, .InvalidAddress, .InvalidAmount, .AbiError,
             .NotImplemented, .InvalidRoute: false
        }
    }
}
