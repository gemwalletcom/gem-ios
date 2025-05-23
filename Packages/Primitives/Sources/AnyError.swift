// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum AnyError: Equatable {
    case message(String)
    case notImplemented
    
    public init(_ message: String) {
        self = .message(message)
    }
}

extension AnyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        case .notImplemented:
            return "Not implemented"
        }
    }
}
