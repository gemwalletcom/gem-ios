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
        case .NoAvailableProvider: Localized.Errors.Swap.notSupportedPair
        case .InputAmountError: Localized.Errors.Swap.amountTooSmall
        case .ComputeQuoteError(let error),
             .TransactionError(let error): error
        case .InvalidRoute: "Invalid Route"
        }
    }
}

extension Gemstone.AlienError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .Network(let msg): msg
        case .Http(let status, _): "HTTP Status: \(status)"
        case .Timeout: URLError(.timedOut).localizedDescription
        case .Serialization(let msg): msg
        }
    }
}
