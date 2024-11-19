// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public enum SwapError: LocalizedError {
    case noQuoteData

    public var errorDescription: String? {
        switch self {
        case .noQuoteData:
            return Localized.Errors.Swap.noQuoteData
        }
    }
}
