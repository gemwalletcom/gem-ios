// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

struct RequiredFieldError: Equatable {
    private let field: String

    init(field: String) {
        self.field = field
    }
}

extension RequiredFieldError: LocalizedError {
    var errorDescription: String? {
        Localized.Errors.required(field)
    }
}
