// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ValidationError: Error {
    case dataNotValid(description: String)
}

extension ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataNotValid(let description):
            return description
        }
    }
}
