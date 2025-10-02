// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Transfer
import PrimitivesTestKit
import BigInt
import Primitives
import PrimitivesComponents

public extension TransactionInputViewModel {
    static func mock(
        data: TransferData = .mock(),
        transactionData: TransactionData? = nil,
        metaData: TransferDataMetadata? = nil,
        transferAmount: TransferAmountValidation? = nil
    ) -> TransactionInputViewModel {
        TransactionInputViewModel(
            data: data,
            transactionData: transactionData,
            metaData: metaData,
            transferAmount: transferAmount
        )
    }
}
