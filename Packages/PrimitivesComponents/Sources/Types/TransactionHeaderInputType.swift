// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public enum TransactionHeaderInputType: Sendable {
    case amount(showFiatSubtitle: Bool)
    case nft(name: String?, id: String)
    case swap(SwapHeaderInput)
    case symbol
}
