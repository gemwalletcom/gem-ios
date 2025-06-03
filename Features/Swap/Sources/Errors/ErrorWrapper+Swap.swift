// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import enum Gemstone.SwapperError

public struct ErrorWrapper: Error, LocalizedError {
    private let error: Error

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
                 .TransactionError: error.localizedDescription
            }
        default: error.localizedDescription
        }
    }
}
