// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public struct RequiredFieldError: Equatable {
    private let field: String

    public init(field: String) {
        self.field = field
    }
}

extension RequiredFieldError: LocalizedError {
    public var errorDescription: String? {
        Localized.Errors.required(field)
    }
}
