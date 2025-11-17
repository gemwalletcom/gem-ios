// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ScanAddressTarget {
    static func mock(assetId: AssetId = AssetId(chain: .sui), address: String = "addr") -> Self {
        .init(assetId: assetId, address: address)
    }
}
