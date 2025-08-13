// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol SwapAssetsProvider: Sendable {
    func supportedChains() -> [Chain]
}