// Copyright (c). Gem Wallet. All rights reserved.

import Localization
import Foundation

enum URLValidationError: LocalizedError {
    case invalidUrl

    var errorDescription: String? {
        switch self {
        case .invalidUrl: Localized.Errors.invalidUrl
        }
    }
}
