// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperSwapResult
import enum Gemstone.SwapperSwapStatus
import Primitives

public extension SwapperSwapResult {
    func asPrimitives() throws -> SwapResult {
        guard let primitiveFromChain = Chain(rawValue: fromChain) else {
            throw AnyError("Invalid swap result chain: \(fromChain)")
        }

        let destinationChain = try toChain.map { chainId -> Chain in
            guard let chain = Chain(rawValue: chainId) else {
                throw AnyError("Invalid destination chain: \(chainId)")
            }
            return chain
        }

        return SwapResult(
            status: SwapStatus(status),
            fromChain: primitiveFromChain,
            fromTxHash: fromTxHash,
            toChain: destinationChain,
            toTxHash: toTxHash
        )
    }
}

private extension SwapStatus {
    init(_ status: SwapperSwapStatus) {
        switch status {
        case .pending: self = .pending
        case .completed: self = .completed
        case .failed: self = .failed
        case .refunded: self = .refunded
        }
    }
}
