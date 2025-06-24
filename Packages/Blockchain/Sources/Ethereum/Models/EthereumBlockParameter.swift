// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum EthereumBlockParameter: String, Sendable {
    case latest
    case earliest
    case pending
    case finalized
    case safe
}
