// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol AssetDiscoverable: Sendable {
    func discoverAssets(wallet: Wallet) async throws
}
