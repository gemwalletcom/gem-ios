// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ChainNodeViewModel {
    let chainNode: ChainNode
    
    var title: String {
        guard let host = chainNode.host else {
            return ""
        }
        if host.contains("gemnodes.com") {
            return "Gem Wallet Node"
        }
        return host
    }
}

extension ChainNode {
    var host: String? {
        return URL(string: node.url)?.host
    }
}
