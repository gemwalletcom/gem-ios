// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation

struct CustomNodeULRFetchable: NodeURLFetchable {
    let url: URL

    func node(for chain: Chain) -> URL { url }
}
