// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Result {
    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }
}
