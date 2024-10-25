// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol NodeURLFetchable {
    func node(for chain: Chain) -> URL
}
