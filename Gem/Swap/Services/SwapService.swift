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
    
    static func getRouter(chain: Chain) throws -> String {
        guard let evmChain = EVMChain(rawValue: chain.rawValue) else {
            throw AnyError("Not EVM compatible chain!")
        }

        guard let router = Config.shared.config(for: evmChain).oneinch.first else {
            throw AnyError("Doesn't support \(evmChain.rawValue) chain yet!")
        }
        return router
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
