// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum JobStatus: Sendable {
    case success
    case failure
    case retry(Duration)
}
