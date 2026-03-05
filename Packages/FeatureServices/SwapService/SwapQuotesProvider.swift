// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperProviderType

public protocol SwapQuotesProvidable: Sendable {
    func supportedAssets(for assetId: AssetId) -> ([Primitives.Chain], [Primitives.AssetId])
    func fetchQuotes(wallet: Wallet, input: SwapQuoteInput) -> AsyncStream<Result<SwapperQuote, Error>>
}

public struct SwapQuotesProvider: SwapQuotesProvidable {
    private let swapService: SwapService

    public init(swapService: SwapService) {
        self.swapService = swapService
    }

    public func supportedAssets(for assetId: AssetId) -> ([Primitives.Chain], [Primitives.AssetId]) {
        swapService.supportedAssets(for: assetId)
    }

    public func fetchQuotes(wallet: Wallet, input: SwapQuoteInput) -> AsyncStream<Result<SwapperQuote, Error>> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    let walletAddress = try wallet.account(for: input.fromAsset.chain).address
                    let destinationAddress = try wallet.account(for: input.toAsset.chain).address
                    let providers = try swapService.getProvidersForQuote(input: input, walletAddress: walletAddress, destinationAddress: destinationAddress)
                    await fetchFromProviders(providers, input: input, walletAddress: walletAddress, destinationAddress: destinationAddress, continuation: continuation)
                } catch {
                    continuation.yield(.failure(error))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func fetchFromProviders(_ providers: [SwapperProviderType], input: SwapQuoteInput, walletAddress: String, destinationAddress: String, continuation: AsyncStream<Result<SwapperQuote, Error>>.Continuation) async {
        await withTaskGroup(of: Result<SwapperQuote, Error>?.self) { group in
            for provider in providers {
                group.addTask { [swapService] in
                    guard !Task.isCancelled else { return nil }
                    do {
                        let quote = try await swapService.getQuoteByProvider(provider: provider.id, input: input, walletAddress: walletAddress, destinationAddress: destinationAddress)
                        return .success(quote)
                    } catch {
                        guard !Task.isCancelled else { return nil }
                        return .failure(error)
                    }
                }
            }
            for await result in group {
                if let result {
                    continuation.yield(result)
                }
            }
        }
    }
}
