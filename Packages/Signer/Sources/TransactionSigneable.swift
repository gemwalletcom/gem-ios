// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol TransactionSigneable: Sendable {
    func sign(
        transfer: TransferData,
        transactionLoad: TransactionLoad,
        amount: TransferAmount,
        wallet: Wallet
    ) throws -> [String]
}
