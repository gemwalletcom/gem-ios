// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum ScanError: Error, Equatable, Sendable {
    case malicious
    case memoRequired(chain: Chain)
}
