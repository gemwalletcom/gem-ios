// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import Localization

public enum ScanTransactionError: Error, Equatable, Sendable {
    case malicious
    case memoRequired(chain: Chain)
}

extension ScanTransactionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .malicious: Localized.Errors.ScanTransaction.malicious
        case .memoRequired(let chain): Localized.Errors.ScanTransaction.memoRequired(chain.asset.symbol)
        }
    }
}
