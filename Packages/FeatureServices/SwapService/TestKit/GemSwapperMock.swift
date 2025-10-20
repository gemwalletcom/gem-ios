// Copyright (c). Gem Wallet. All rights reserved.

import typealias Gemstone.AssetId
import typealias Gemstone.Chain
import enum Gemstone.FetchQuoteData
import protocol Gemstone.GemSwapperProtocol
import struct Gemstone.GemSwapQuoteData
import struct Gemstone.Permit2ApprovalData
import struct Gemstone.SwapperAssetList
import enum Gemstone.SwapperProvider
import struct Gemstone.SwapperProviderType
import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperQuoteRequest
import struct Gemstone.SwapperSwapResult

public final class GemSwapperMock: GemSwapperProtocol {
    private let permit2ForQuote: Permit2ApprovalData
    private let quotes: [SwapperQuote]
    private let quoteByProvider: SwapperQuote
    private let quoteData: GemSwapQuoteData
    private let providers: [SwapperProviderType]
    private let transactionStatus: Bool
    private let chains: [Chain]
    private let swapAssetList: SwapperAssetList
    private let swapResult: SwapperSwapResult

    public init(
        permit2ForQuote: Permit2ApprovalData = .mock(),
        quotes: [SwapperQuote] = [.mock()],
        quoteByProvider: SwapperQuote = .mock(),
        quoteData: GemSwapQuoteData = .mock(),
        providers: [SwapperProviderType] = [.mock()],
        transactionStatus: Bool = false,
        chains: [Chain] = ["ethereum"],
        swapAssetList: SwapperAssetList = .mock(),
        swapResult: SwapperSwapResult = .mock()
    ) {
        self.permit2ForQuote = permit2ForQuote
        self.quotes = quotes
        self.quoteByProvider = quoteByProvider
        self.quoteData = quoteData
        self.providers = providers
        self.transactionStatus = transactionStatus
        self.chains = chains
        self.swapAssetList = swapAssetList
        self.swapResult = swapResult
    }

    public func fetchPermit2ForQuote(quote: SwapperQuote) async throws -> Permit2ApprovalData? {
        permit2ForQuote
    }

    public func fetchQuote(request: SwapperQuoteRequest) async throws -> [SwapperQuote] {
        quotes
    }

    public func fetchQuoteByProvider(provider: SwapperProvider, request: SwapperQuoteRequest) async throws -> SwapperQuote {
        quoteByProvider
    }

    public func fetchQuoteData(quote: SwapperQuote, data: FetchQuoteData) async throws -> GemSwapQuoteData {
        quoteData
    }

    public func getProviders() -> [SwapperProviderType] {
        providers
    }

    public func getTransactionStatus(chain: Chain, swapProvider: SwapperProvider, transactionHash: String) async throws -> Bool {
        transactionStatus
    }

    public func supportedChains() -> [Chain] {
        chains
    }

    public func supportedChainsForFromAsset(assetId: AssetId) -> SwapperAssetList {
        swapAssetList
    }

    public func getSwapResult(chain: Chain, swapProvider: SwapperProvider, transactionHash: String) async throws -> SwapperSwapResult {
        swapResult
    }
}
