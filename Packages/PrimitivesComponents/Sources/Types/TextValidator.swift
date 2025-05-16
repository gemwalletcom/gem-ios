// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public protocol TextValidator: Sendable, Identifiable {
    func validate(_ text: String) throws
}

public struct UnknownValidationError: LocalizedError {
    public var errorDescription: String? { Localized.Errors.unknown }
}
