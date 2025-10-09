// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.GemSwapper
import GemstonePrimitives
import ChainService
import NativeProviderService
import Primitives

public struct SwapTransactionService: Sendable {
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
    
    public func getTransactionStatus(chain: Primitives.Chain, provider: String?, hash: String) async throws {
        //let provider = SwapProviderConfig
        
        //let provider = SwapProvider.across
        
//        let status = try await swapper.getTransactionStatus(
//            chain: chain.rawValue,
//            swapProvider: .across,
//            transactionHash: hash
//        )
    }
}
