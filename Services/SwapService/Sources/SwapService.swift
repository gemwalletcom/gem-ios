// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Primitives.Chain
import enum Primitives.EVMChain
import enum Primitives.AnyError
import Gemstone
import Primitives
import ChainService

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
            amount: value,
            mode: .exactIn,
            options: GemSwapOptions(
                slippageBps: 100,
                fee: self.getFee(),
                preferredProviders: []
            )
        )
        
        return try await swapper.fetchQuote(request: swapRequest)
    }
    
    public func getQuoteData(_ request: Gemstone.SwapQuote) async throws -> Gemstone.SwapQuoteData {
        let quoteData = try await swapper.fetchQuoteData(quote: request, permit2: .none)
        
        NSLog("request \(request)")
        
        return quoteData
    }
    
    public func permit2() -> Permit2Data {
        let permit = PermitSingle(
            details: Permit2Detail(token: "", amount: "", expiration: 0, nonce: 0),
            spender: "",
            sigDeadline: 0
        )
        return Permit2Data(permitSingle: permit, signature: Data())
    }
}
