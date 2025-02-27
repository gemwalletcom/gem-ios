// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum KeystoreImportType: Sendable {
    case phrase(words: [String], chains: [Chain])
    case single(words: [String], chain: Chain)
    case privateKey(text: String, chain: Chain)
    case address(chain: Chain, address: String)
}
