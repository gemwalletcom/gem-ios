// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import ChainService
import Foundation
import class Gemstone.GemSwapper
import protocol Gemstone.GemSwapperProtocol
import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperQuoteRequest
import struct Gemstone.SwapperQuoteAsset
import struct Gemstone.SwapperOptions
import struct Gemstone.SwapperQuoteData
import struct Gemstone.SwapReferralFees
import enum Gemstone.FetchQuoteData
import struct Gemstone.Permit2ApprovalData
import func Gemstone.getDefaultSlippage
import GemstonePrimitives
import NativeProviderService
import Primitives
import enum Primitives.AnyError
import enum Primitives.Chain
import enum Primitives.EVMChain

public final class SwapService: Sendable {
    private let swapper: GemSwapperProtocol
    private let swapConfig = GemstoneConfig.shared.getSwapConfig()

    public init(swapper: GemSwapperProtocol) {
        self.swapper = swapper
    }

    public convenience init(nodeProvider: any NodeURLFetchable) {
        self.init(swapper: GemSwapper(rpcProvider: NativeProvider(nodeProvider: nodeProvider)))
    }

    private func getReferralFees() -> SwapReferralFees {
        // TODO: In the future fees could be based on the asset you are swapping
        swapConfig.referralFee
    }

    public func supportedChains() -> [Chain] {
        swapper.supportedChains().compactMap { Chain(rawValue: $0) }
    }

    public func supportedAssets(for assetId: Primitives.AssetId) -> ([Primitives.Chain], [Primitives.AssetId]) {
        let swapAssetList = swapper.supportedChainsForFromAsset(assetId: assetId.identifier)

        return (
            swapAssetList.chains.compactMap { try? Primitives.Chain(id: $0) },
            swapAssetList.assetIds.compactMap { try? Primitives.AssetId(id: $0) }
        )
    }

    public func getQuotes(fromAsset: Asset, toAsset: Asset, value: String, walletAddress: String, destinationAddress: String) async throws -> [SwapperQuote] {
        let swapRequest = SwapperQuoteRequest(
            fromAsset: SwapperQuoteAsset(asset: fromAsset),
            toAsset: SwapperQuoteAsset(asset: toAsset),
            walletAddress: walletAddress,
            destinationAddress: destinationAddress,
            value: value,
            mode: .exactIn,
            options: SwapperOptions(
                slippage: getDefaultSlippage(chain: fromAsset.id.chain.rawValue),
                fee: getReferralFees(),
                preferredProviders: []
            )
        )
        let quotes = try await swapper.fetchQuote(request: swapRequest)
        try Task.checkCancellation()
        return quotes
    }

    public func getQuoteData(_ request: SwapperQuote, data: FetchQuoteData) async throws -> SwapperQuoteData {
        let quoteData = try await swapper.fetchQuoteData(quote: request, data: data)
        try Task.checkCancellation()
        return quoteData
    }

    public func getPermit2Approval(quote: SwapperQuote) async throws -> Permit2ApprovalData? {
        try await swapper.fetchPermit2ForQuote(quote: quote)
    }
}
