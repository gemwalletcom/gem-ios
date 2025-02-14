// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import class Gemstone.WalletConnectNamespace
import struct WalletConnectUtils.Blockchain

extension Chain {
    // CAIP-2 https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md
    public var namespace: String? {
        WalletConnectNamespace.shared.getNamespace(chain: id)
    }
    
    // CAIP-20 https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-20.md
    public var reference: String? {
        WalletConnectNamespace.shared.getReference(chain: id)
    }
    
    public var blockchain: Blockchain? {
        if let namespace = namespace, let reference = reference {
            return Blockchain(namespace: namespace, reference: reference)
        }
        return .none
    }
}

extension WalletConnectNamespace {
    static let shared = WalletConnectNamespace()
}
