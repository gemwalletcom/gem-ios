// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Signer
import Primitives

public struct TransactionSignerMock: TransactionSigneable {
    public let signedData: [String]

    public init(signedData: [String] = ["signed_data"]) {
        self.signedData = signedData
    }

    public func sign(
        transfer: TransferData,
        transactionData: TransactionData,
        amount: TransferAmount,
        wallet: Wallet
    ) throws -> [String] {
        signedData
    }
}
