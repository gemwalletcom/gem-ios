// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol TransactionSigneable: Sendable {
    func sign(
        transfer: TransferData,
        transactionData: TransactionData,
        amount: TransferAmount,
        wallet: Wallet
    ) async throws -> [String]
}
