// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Result {
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    var isFailure: Bool { !isSuccess }
}
