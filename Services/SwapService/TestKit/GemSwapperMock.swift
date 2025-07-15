// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone

public final class GemSwapperMock: GemSwapperProtocol {
    private let permit2ForQuote: Permit2ApprovalData
    private let quotes: [Gemstone.SwapQuote]
    private let quoteByProvider: Gemstone.SwapQuote
    private let quoteData: Gemstone.SwapperQuoteData
    private let providers: [Gemstone.SwapProviderType]
    private let transactionStatus: Bool
    private let chains: [Gemstone.Chain]
    private let swapAssetList: Gemstone.SwapAssetList

    public init(
        permit2ForQuote: Permit2ApprovalData = .mock(),
        quotes: [Gemstone.SwapQuote] = [.mock()],
        quoteByProvider: Gemstone.SwapQuote = .mock(),
        quoteData: Gemstone.SwapperQuoteData = .mock(),
        providers: [Gemstone.SwapProviderType] = [.mock()],
        transactionStatus: Bool = false,
        chains: [Gemstone.Chain] = ["ethereum"],
        swapAssetList: Gemstone.SwapAssetList = .mock()
    ) {
        self.permit2ForQuote = permit2ForQuote
        self.quotes = quotes
        self.quoteByProvider = quoteByProvider
        self.quoteData = quoteData
        self.providers = providers
        self.transactionStatus = transactionStatus
        self.chains = chains
        self.swapAssetList = swapAssetList
    }
    
    public func fetchPermit2ForQuote(quote: SwapQuote) async throws -> Permit2ApprovalData? {
        permit2ForQuote
    }
    
    public func fetchQuote(request: Gemstone.SwapQuoteRequest) async throws -> [Gemstone.SwapQuote] {
        quotes
    }
    
    public func fetchQuoteByProvider(provider: Gemstone.GemSwapProvider, request: Gemstone.SwapQuoteRequest) async throws -> Gemstone.SwapQuote {
        quoteByProvider
    }
    
    public func fetchQuoteData(quote: Gemstone.SwapQuote, data: Gemstone.FetchQuoteData) async throws -> Gemstone.SwapperQuoteData {
        quoteData
    }
    
    public func getProviders() -> [Gemstone.SwapProviderType] {
        providers
    }
    
    public func getTransactionStatus(chain: Gemstone.Chain, swapProvider: Gemstone.GemSwapProvider, transactionHash: String) async throws -> Bool {
        transactionStatus
    }
    
    public func supportedChains() -> [Gemstone.Chain] {
        chains
    }
    
    public func supportedChainsForFromAsset(assetId: Gemstone.AssetId) -> Gemstone.SwapAssetList {
        swapAssetList
    }
}
