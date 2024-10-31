// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Primitives.Chain
import enum Primitives.EVMChain
import enum Primitives.AnyError
import struct Primitives.SwapQuote
import Gemstone
import struct Primitives.SwapQuoteRequest
import struct Primitives.SwapQuoteResult
import struct Primitives.SwapProvider
import struct Primitives.SwapQuoteData

import ChainService

public final class SwapService {
    
    private let nodeProvider: any NodeURLFetchable
    private let swapper: GemSwapper
    
    var quote: GemSwapQuote?
    
    public init(
        nodeProvider: any NodeURLFetchable
    ) {
        self.nodeProvider = nodeProvider
        self.swapper = GemSwapper(rpcProvider: NativeProvider(nodeProvider: nodeProvider))
    }
    
    public func getQuote(_ request: Primitives.SwapQuoteRequest) async throws -> Primitives.SwapQuoteResult {
        let swapRequest = Gemstone.SwapQuoteRequest(
            fromAsset: request.fromAsset,
            toAsset: request.toAsset,
            walletAddress: request.walletAddress,
            destinationAddress: request.walletAddress,
            amount: request.amount,
            mode: .exactIn,
            options: GemSwapOptions(
                slippageBps: 100,
                fee: GemSwapFee(bps: 50, address: "0x0D9DAB1A248f63B0a48965bA8435e4de7497a3dC"),
                preferredProviders: []
            )
        )
        
        let quote = try await swapper.fetchQuote(request: swapRequest)
        
        self.quote = quote
        
        return Primitives.SwapQuoteResult(
            quote: SwapQuote(
                chainType: .ethereum,
                fromAmount: quote.fromValue,
                toAmount: quote.toValue,
                feePercent: 0,
                provider: SwapProvider(name: ""),
                data: .none,
                approval: .none
            )
        )
    }
    
    public func getQuoteData(_ request: Primitives.SwapQuoteRequest) async throws -> Primitives.SwapQuoteResult {
        let quoteData = try await swapper.fetchQuoteData(quote: self.quote!, permit2: .none)
        
        return Primitives.SwapQuoteResult(
            quote: SwapQuote(
                chainType: .ethereum,
                fromAmount: self.quote!.fromValue,
                toAmount: self.quote!.toValue,
                feePercent: 0,
                provider: SwapProvider(name: ""),
                data: SwapQuoteData(to: quoteData.to, value: quoteData.value, data: quoteData.data),
                approval: .none
            )
        )
    }
}
