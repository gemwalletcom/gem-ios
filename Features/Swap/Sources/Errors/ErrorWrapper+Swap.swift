// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Gemstone.SwapperError
import Localization

public struct ErrorWrapper: Error, LocalizedError {
    public let error: Error

    public init(_ error: Error) {
        self.error = error
    }

    public var errorDescription: String? {
        switch error {
        case let swapperError as Gemstone.SwapperError:
            switch swapperError {
            case .NotSupportedChain: Localized.Errors.Swap.notSupportedChain
            case .NotSupportedAsset: Localized.Errors.Swap.notSupportedAsset
            case .NoQuoteAvailable: Localized.Errors.Swap.noQuoteAvailable
            case .NotSupportedPair, .NoAvailableProvider: Localized.Errors.Swap.notSupportedPair
            case .InputAmountTooSmall: Localized.Errors.Swap.amountTooSmall
            case .InvalidAddress,
                 .InvalidAmount,
                 .NetworkError,
                 .AbiError,
                 .NotImplemented,
                 .ComputeQuoteError,
                 .InvalidRoute,
                 .TransactionError: swapperError.underlyingError
            }
        default: error.localizedDescription
        }
    }
}

public extension Gemstone.SwapperError {
    var underlyingError: String {
        switch self {
        case .NotSupportedChain,
             .NotSupportedAsset,
             .NotSupportedPair,
             .NoAvailableProvider,
             .InputAmountTooSmall,
             .InvalidRoute,
             .NoQuoteAvailable,
             .NotImplemented:
            return localizedDescription
        case .InvalidAddress(let error),
             .InvalidAmount(let error),
             .NetworkError(let error),
             .AbiError(let error),
             .ComputeQuoteError(let error),
             .TransactionError(let error):
            return error
        }
    }
}
