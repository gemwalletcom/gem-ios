// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ScanService

extension ScanError: @retroactive LocalizedError {
    // TODO:- Localize
    public var errorDescription: String? {
        switch self {
        case .malicious: "Denied. Transaction looks malicious."
        case .memoRequired(let chain): "\(chain.asset.symbol) address requires a destination tag / memo."
        }
    }
}
