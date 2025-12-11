// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public extension Primitives.Chain {
    func messageSignatureScheme() throws -> GemSignatureScheme {
        switch type {
        case .solana:
            return .ed25519
        case .ethereum:
            return .secp256k1
        default:
            throw AnyError("Unsupported message signing for chain \(rawValue)")
        }
    }
}

