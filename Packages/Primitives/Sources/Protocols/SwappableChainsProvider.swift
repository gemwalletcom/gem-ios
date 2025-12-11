// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol SwappableChainsProvider: Sendable {
    func supportedChains() -> [Chain]
}
