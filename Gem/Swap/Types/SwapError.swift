// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum SwapError: LocalizedError {
    case noQuoteData

    var errorDescription: String? {
        switch self {
        case .noQuoteData:
            return "No Quote data"
        }
    }
}
