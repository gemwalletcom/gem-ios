// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

extension Chain {
    // CAIP-2 https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md
    public var namespace: String? {
        WalletConnectNamespace().getNamespace(chain: id)
    }
    
    // CAIP-20 https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-20.md
    public var reference: String? {
        WalletConnectNamespace().getReference(chain: id)
    }
}
