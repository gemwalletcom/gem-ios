// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import protocol Gemstone.GemSwapperProtocol
import GemstonePrimitives
import Primitives

struct SwapResultProvider: Sendable {
    private let swapper: any GemSwapperProtocol

    init(swapper: any GemSwapperProtocol) {
        self.swapper = swapper
    }

    func checkSwapStatus(for transaction: Transaction) async throws -> TransactionState? {
        guard let provider = transaction.swapProvider.flatMap(SwapProvider.init(rawValue:)) else {
            return .failed
        }

        let result = try await swapper.getSwapResult(chain: transaction.chain.rawValue, provider: provider.map(), transactionHash: transaction.id.hash).map()

        switch result.status {
        case .completed: return .confirmed
        case .failed: return .failed
        case .pending: return nil
        }
    }
}
