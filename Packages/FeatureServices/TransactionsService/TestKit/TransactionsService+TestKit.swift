// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import TransactionsService
import StoreTestKit
import AssetsServiceTestKit
import DeviceServiceTestKit
import SwapService
import Primitives

public extension TransactionsService {
    static func mock() -> TransactionsService {
        TransactionsService(
            transactionStore: .mock(),
            assetsService: .mock(),
            walletStore: .mock(),
            deviceService: DeviceServiceMock(),
            addressStore: .mock(),
            swapTransactionService: SwapStatusProvidingMock()
        )
    }
}

private struct SwapStatusProvidingMock: SwapStatusProviding {
    func getSwapResult(
        providerId: String?,
        chain: Chain,
        transactionId: String,
        memo: String?
    ) async throws -> SwapResult {
        SwapResult(status: .pending, fromChain: chain, fromTxHash: transactionId, toChain: nil, toTxHash: nil)
    }
}
