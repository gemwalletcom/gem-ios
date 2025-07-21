// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ScanAddressTarget {
    static func mock(chain: Chain = .sui, address: String = "addr") -> Self {
        .init(chain: chain, address: address)
    }
}
