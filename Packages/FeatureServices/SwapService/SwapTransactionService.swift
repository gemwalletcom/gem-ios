// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.GemSwapper
import enum Gemstone.SwapperProvider
import struct Gemstone.SwapperSwapResult
import class Gemstone.SwapProviderConfig
import GemstonePrimitives
import NativeProviderService
import Primitives

public protocol SwapStatusProviding: Sendable {
    func getSwapResult(
        providerId: String?,
        chain: Primitives.Chain,
        transactionId: String,
        memo: String?
    ) async throws -> SwapResult
}

public struct SwapTransactionService: SwapStatusProviding, Sendable {
    private let swapper: GemSwapper

    public init(nodeProvider: any NodeURLFetchable) {
        swapper = GemSwapper(rpcProvider: NativeProvider(nodeProvider: nodeProvider))
    }

    public func getSwapResult(
        providerId: String?,
        chain: Primitives.Chain,
        transactionId: String,
        memo: String?
    ) async throws -> SwapResult {
        guard let providerId, !providerId.isEmpty else {
            throw AnyError("Swap provider is missing")
        }

        guard let swapProvider = providerId.toSwapperProvider() else {
            throw AnyError("Invalid swap provider: \(providerId)")
        }

        let transactionHash = if swapProvider == .nearIntents, let memo, !memo.isEmpty {
            memo
        } else {
            transactionId
        }
        let result = try await swapper.getSwapResult(
            chain: chain.rawValue,
            swapProvider: swapProvider,
            transactionHash: transactionHash
        )

        return try result.asPrimitives()
    }
}

private extension String {
    func toSwapperProvider() -> SwapperProvider? {
        SwapProviderConfig.fromString(id: self).inner().id
    }
}
