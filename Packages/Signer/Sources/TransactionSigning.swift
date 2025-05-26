// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol TransactionSigning: Sendable {
    func sign(
        transfer: TransferData,
        preload: TransactionLoad,
        amount: TransferAmount,
        wallet: Wallet
    ) throws -> [String]
}
