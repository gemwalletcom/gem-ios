// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import BigInt
import Blockchain
import Gemstone
import GemstonePrimitives

class SwapService {
    
    let provider: GemAPISwapService
    
    static func getSpender(chain: Chain, quote: SwapQuote?) throws -> String {

        guard let spender = quote?.approval?.spender else {
            throw AnyError("Approval data is nil!")
        }

        guard let evmChain = EVMChain(rawValue: chain.rawValue) else {
            throw AnyError("Not EVM compatible chain!")
        }
        
        let contracts = Config.shared.config(for: evmChain).oneinch
        guard contracts.contains(spender) else {
            throw AnyError("Not whitelisted spender \(spender)")
        }
        return spender
    }

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
