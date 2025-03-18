// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum CopyType: Hashable, Equatable, Sendable {
    case secretPhrase
    case privateKey
    case address(Asset, address: String)
}
