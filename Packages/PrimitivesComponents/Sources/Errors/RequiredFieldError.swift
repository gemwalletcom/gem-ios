// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public enum RequiredFieldError: Equatable {
    case field(name: String)
}

extension RequiredFieldError: LocalizedError {
    public var errorDescription: String? {
        guard case .field(let name) = self else {
            return .none
        }
        return Localized.Errors.required(name)
    }
}
