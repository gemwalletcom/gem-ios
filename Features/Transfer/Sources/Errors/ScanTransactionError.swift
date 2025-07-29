// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public enum ScanTransactionError: Error, Equatable, Sendable {
    case malicious
    case memoRequired(symbol: String)
}

extension ScanTransactionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .malicious: Localized.Errors.ScanTransaction.malicious
        case .memoRequired(let symbol): Localized.Errors.ScanTransaction.memoRequired(symbol)
        }
    }
}
