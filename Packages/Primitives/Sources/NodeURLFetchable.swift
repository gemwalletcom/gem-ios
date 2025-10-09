// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol NodeURLFetchable: Sendable {
    func node(for chain: Chain) -> URL
}