// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import class Gemstone.WalletConnect
import struct WalletConnectUtils.Blockchain

extension Chain {
    // CAIP-2 https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md
    var namespace: String? {
        WalletConnect.shared.getNamespace(chain: id)
    }

    // CAIP-20 https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-20.md
    var reference: String? {
        WalletConnect.shared.getReference(chain: id)
    }

    var blockchain: Blockchain? {
        if let namespace = namespace, let reference = reference {
            return Blockchain(namespace: namespace, reference: reference)
        }
        return .none
    }
}

extension Blockchain {
    public var chain: Chain? {
        guard let chain = WalletConnect.shared.getChain(caip2: namespace, caip10: reference) else {
            return .none
        }
        return Chain(rawValue: chain)
    }
}

extension WalletConnect {
    static let shared = WalletConnect()
}
