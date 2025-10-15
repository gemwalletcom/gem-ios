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
        providerId: SwapProvider,
        chain: Primitives.Chain,
        transactionId: String,
        recipient: String
    ) async throws -> SwapResult
}

public struct SwapTransactionService: SwapStatusProviding, Sendable {
    private let swapper: GemSwapper

    public init(nodeProvider: any NodeURLFetchable) {
        swapper = GemSwapper(rpcProvider: NativeProvider(nodeProvider: nodeProvider))
    }

    func shouldUpdate(id: SwapProvider) -> Bool {
        let providerConfig = SwapProviderConfig.fromString(id: id.rawValue)
        return providerConfig.inner().mode != .onChain
    }

    public func getSwapResult(
        providerId: SwapProvider,
        chain: Primitives.Chain,
        transactionId: String,
        recipient: String
    ) async throws -> SwapResult {
        let swapProvider = SwapProviderConfig.fromString(id: providerId.rawValue).inner().id
        let transactionHash = if swapProvider == .nearIntents {
            recipient
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
