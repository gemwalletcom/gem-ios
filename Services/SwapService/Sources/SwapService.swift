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

public final class SwapService {
    
    private let nodeProvider: any NodeURLFetchable
    private let swapper: GemSwapper
    private let swapConfig = GemstoneConfig.shared.getSwapConfig()
    
    public init(
        nodeProvider: any NodeURLFetchable
    ) {
        self.nodeProvider = nodeProvider
        self.swapper = GemSwapper(rpcProvider: NativeProvider(nodeProvider: nodeProvider))
    }
    
    func getFee(fromAsset: Primitives.AssetId) -> GemSwapFee {
        
        return GemSwapFee(
            bps: swapConfig.referralFee.evm.bps,
            address: swapConfig.referralFee.evm.address
        )
    }
    
    public func getQuote(fromAsset: Primitives.AssetId, toAsset: Primitives.AssetId, value: String, walletAddress: String) async throws -> [Gemstone.SwapQuote] {
        let swapRequest = Gemstone.SwapQuoteRequest(
            fromAsset: fromAsset.identifier,
            toAsset: toAsset.identifier,
            walletAddress: walletAddress,
            destinationAddress: walletAddress,
            value: value,
            mode: .exactIn,
            options: GemSwapOptions(
                slippageBps: swapConfig.slippageBps,
                fee: self.getFee(fromAsset: fromAsset),
                preferredProviders: []
            )
        )
        
        return try await swapper.fetchQuote(request: swapRequest)
    }
    
    public func getQuoteData(_ request: Gemstone.SwapQuote, data: FetchQuoteData) async throws -> Gemstone.SwapQuoteData {
        return try await swapper.fetchQuoteData(quote: request, data: data)
    }
}
