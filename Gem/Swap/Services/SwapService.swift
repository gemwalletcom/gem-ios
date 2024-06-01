// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import BigInt
import Blockchain

class SwapService {
    
    let provider: GemAPISwapService
    //let ethereumSwapService: EthereumSwapService
    
    static let oneinch = "0x1111111254EEB25477B68fb85Ed929f73A960582"
    
    init(
        provider: GemAPISwapService = GemAPIService()
    ) {
        self.provider = provider
    }
    
    func getQuote(request: SwapQuoteRequest) async throws -> SwapQuoteResult {
        return try await provider.getSwap(request: request)
    }
    
    func getAllowance(chain: Chain, contract: String, owner: String, spender: String) async throws -> BigInt {
        let evmChain = EVMChain(rawValue: chain.rawValue)!
        let service = EthereumSwapService(chain: evmChain, provider: ProviderFactory.create(with: evmChain.chain.defaultBaseUrl))
        return try await service.getAllowance(contract: contract, owner: owner, spender: spender)
    }
}
