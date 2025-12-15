// Copyright (c). Gem Wallet. All rights reserved.

import Localization
import Foundation

public struct URLValidationError: LocalizedError {
    public var errorDescription: String? { Localized.Errors.invalidUrl }
}
