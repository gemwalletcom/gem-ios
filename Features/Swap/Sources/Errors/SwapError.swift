// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public enum SwapError: LocalizedError, Sendable {
    case noQuoteData

    public var errorDescription: String? {
        switch self {
        case .noQuoteData: Localized.Errors.Swap.noQuoteData
        }
    }
}
