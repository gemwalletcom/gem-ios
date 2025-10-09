// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct BalanceUpdateError {
    public let chain: Chain
    public let error: any Error
}
