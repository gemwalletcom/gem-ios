// Copyright (c). Gem Wallet. All rights reserved.

import Localization
import Foundation

public enum URLValidationError: LocalizedError {
    case invalidUrl

    public var errorDescription: String? {
        switch self {
        case .invalidUrl: Localized.Errors.invalidUrl
        }
    }
}
