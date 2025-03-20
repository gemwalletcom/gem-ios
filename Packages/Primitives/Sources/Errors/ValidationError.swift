// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ValidationError: Error {
    case invalid(description: String)
}

extension ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalid(let description):
            return description
        }
    }
}
