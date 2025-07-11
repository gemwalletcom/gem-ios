// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol RetryableError {
    var isRetryAvailable: Bool { get }
}