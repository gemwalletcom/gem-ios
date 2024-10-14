// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

enum SwapError: LocalizedError {
    case noQuoteData

    var errorDescription: String? {
        switch self {
        case .noQuoteData:
            return Localized.Errors.Swap.noQuoteData
        }
    }
}
