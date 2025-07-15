// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone

public final class GemSwapperMock: GemSwapperProtocol {
    private let permit2ForQuote: Permit2ApprovalData
    private let quotes: [Gemstone.SwapperQuote]
    private let quoteByProvider: Gemstone.SwapperQuote
    private let quoteData: Gemstone.SwapperQuoteData
    private let providers: [Gemstone.SwapperProviderType]
    private let transactionStatus: Bool
    private let chains: [Gemstone.Chain]
    private let swapAssetList: Gemstone.SwapperAssetList

    public init(
        permit2ForQuote: Permit2ApprovalData = .mock(),
        quotes: [Gemstone.SwapperQuote] = [.mock()],
        quoteByProvider: Gemstone.SwapperQuote = .mock(),
        quoteData: Gemstone.SwapperQuoteData = .mock(),
        providers: [Gemstone.SwapperProviderType] = [.mock()],
        transactionStatus: Bool = false,
        chains: [Gemstone.Chain] = ["ethereum"],
        swapAssetList: Gemstone.SwapperAssetList = .mock()
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
    
    public func fetchPermit2ForQuote(quote: SwapperQuote) async throws -> Permit2ApprovalData? {
        permit2ForQuote
    }
    
    public func fetchQuote(request: Gemstone.SwapperQuoteRequest) async throws -> [Gemstone.SwapperQuote] {
        quotes
    }
    
    public func fetchQuoteByProvider(provider: Gemstone.SwapperProvider, request: Gemstone.SwapperQuoteRequest) async throws -> Gemstone.SwapperQuote {
        quoteByProvider
    }
    
    public func fetchQuoteData(quote: Gemstone.SwapperQuote, data: Gemstone.FetchQuoteData) async throws -> Gemstone.SwapperQuoteData {
        quoteData
    }
    
    public func getProviders() -> [Gemstone.SwapperProviderType] {
        providers
    }
    
    public func getTransactionStatus(chain: Gemstone.Chain, swapProvider: Gemstone.SwapperProvider, transactionHash: String) async throws -> Bool {
        transactionStatus
    }
    
    public func supportedChains() -> [Gemstone.Chain] {
        chains
    }
    
    public func supportedChainsForFromAsset(assetId: Gemstone.AssetId) -> Gemstone.SwapperAssetList {
        swapAssetList
    }
}
