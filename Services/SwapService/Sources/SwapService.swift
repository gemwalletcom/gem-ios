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

public final class SwapService {
    
    private let nodeProvider: any NodeURLFetchable
    private let swapper: GemSwapper
    
    public init(
        nodeProvider: any NodeURLFetchable
    ) {
        self.nodeProvider = nodeProvider
        self.swapper = GemSwapper(rpcProvider: NativeProvider(nodeProvider: nodeProvider))
    }
    
    func getFee() -> GemSwapFee {
        GemSwapFee(bps: 50, address: "0x0D9DAB1A248f63B0a48965bA8435e4de7497a3dC")
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
                slippageBps: 100,
                fee: self.getFee(),
                preferredProviders: []
            )
        )
        
        return try await swapper.fetchQuote(request: swapRequest)
    }
    
    public func getQuoteData(_ request: Gemstone.SwapQuote, permit2: Permit2Data?) async throws -> Gemstone.SwapQuoteData {
        return try await swapper.fetchQuoteData(quote: request, permit2: permit2)
    }
}
