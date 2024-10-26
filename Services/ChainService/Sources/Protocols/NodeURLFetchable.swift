// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol NodeURLFetchable: Sendable {
    func node(for chain: Chain) -> URL
}
