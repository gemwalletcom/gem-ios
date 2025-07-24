// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum PerpetualError: Error, LocalizedError {
    case marketNotFound(symbol: String)
    
    public var errorDescription: String? {
        switch self {
        case .marketNotFound(let symbol):
            return "Market not found for symbol: \(symbol)"
        }
    }
}