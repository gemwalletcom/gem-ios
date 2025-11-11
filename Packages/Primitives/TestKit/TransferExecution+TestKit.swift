// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension TransferExecution {
    public static func mock(
        wallet: Wallet = .mock(),
        state: ExecutionState = .executing,
        transferData: TransferData = .mock()
    ) -> TransferExecution {
        TransferExecution(
            wallet: wallet,
            state: state,
            transferData: transferData
        )
    }
}
