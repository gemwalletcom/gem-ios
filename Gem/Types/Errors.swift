// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Localization
import Primitives

extension Gemstone.GatewayError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NetworkError(let string): string
        case .PlatformError(let string): string
        }
    }
}

extension Gemstone.GemstoneError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .AnyError(let string): string
        }
    }
}

extension Gemstone.SwapperError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NotSupportedChain: Localized.Errors.Swap.notSupportedChain
        case .NotSupportedAsset: Localized.Errors.Swap.notSupportedAsset
        case .NoQuoteAvailable: Localized.Errors.Swap.noQuoteAvailable
        case .NotSupportedPair, .NoAvailableProvider: Localized.Errors.Swap.notSupportedPair
        case .InputAmountTooSmall: Localized.Errors.Swap.amountTooSmall
        case .InvalidAddress(let error),
                .InvalidAmount(let error),
                .NetworkError(let error),
                .AbiError(let error),
                .ComputeQuoteError(let error),
                .TransactionError(let error): error
        case .InvalidRoute: "Invalid Route"
        case .NotImplemented: AnyError.notImplemented.errorDescription
        }
    }
}

extension Gemstone.AlienError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .RequestError(msg: let msg): msg
        case .ResponseError(msg: let msg):  msg
        case .Http(let status, _): "Response Status: \(status)"
        }
    }
}
