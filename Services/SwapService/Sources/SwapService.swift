// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Primitives.Chain
import enum Primitives.EVMChain
import enum Primitives.AnyError
import Gemstone
import Primitives
import ChainService
import BigInt
import Signer
import NativeProviderService
import GemstonePrimitives

public final class SwapService: Sendable {
    
    private let nodeProvider: any NodeURLFetchable
    private let swapper: GemSwapper
    private let swapConfig = GemstoneConfig.shared.getSwapConfig()
    
    public init(
        nodeProvider: any NodeURLFetchable
    ) {
        self.nodeProvider = nodeProvider
        self.swapper = GemSwapper(
            rpcProvider: NativeProvider(nodeProvider: nodeProvider)
        )
    }
    
    private func getReferralFees() -> SwapReferralFees {
        //TODO: In the future fees could be based on the asset you are swapping
        swapConfig.referralFee
    }
    
    public func supportedChains() -> [Chain] {
        swapper.supportedChains().compactMap { Chain(rawValue: $0) }
    }
    
    public func supportedAssets(for assetId: Primitives.AssetId) -> ([Primitives.Chain], [Primitives.AssetId]) {
        let swapAssetList = swapper.supportedChainsForFromAsset(assetId: assetId.identifier)
        
        return (
            swapAssetList.chains.compactMap { try? Primitives.Chain(id: $0)},
            swapAssetList.assetIds.compactMap { try? Primitives.AssetId(id: $0) }
        )
    }
    
    public func getQuotes(fromAsset: Primitives.AssetId, toAsset: Primitives.AssetId, value: String, walletAddress: String, destinationAddress: String) async throws -> [Gemstone.SwapQuote] {
        let swapRequest = Gemstone.SwapQuoteRequest(
            fromAsset: fromAsset.identifier,
            toAsset: toAsset.identifier,
            walletAddress: walletAddress,
            destinationAddress: destinationAddress,
            value: value,
            mode: .exactIn,
            options: GemSwapOptions(
                slippage: getDefaultSlippage(chain: fromAsset.chain.rawValue),
                fee: getReferralFees(),
                preferredProviders: []
            )
        )
        let quotes = try await swapper.fetchQuote(request: swapRequest)
        try Task.checkCancellation()
        return quotes
    }
    
    public func getQuoteData(_ request: Gemstone.SwapQuote, data: FetchQuoteData) async throws -> Gemstone.SwapQuoteData {
        let quoteData = try await swapper.fetchQuoteData(quote: request, data: data)
        try Task.checkCancellation()
        return quoteData
    }
    
    public func getPermit2Approval(quote: Gemstone.SwapQuote) async throws -> Permit2ApprovalData? {
        try await swapper.fetchPermit2ForQuote(quote: quote)
    }
}
