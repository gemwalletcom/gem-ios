// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import BigInt
import Blockchain
import Gemstone
import GemstonePrimitives

class SwapService {
    
    private let provider: GemAPISwapService
    private let nodeProvider: NodeURLFetchable
    
    static func getSpender(chain: Chain, quote: SwapQuote?) throws -> String {

        guard let spender = quote?.approval?.spender else {
            throw AnyError("Approval data is nil!")
        }
        let evmChain = try EVMChain(from: chain)
        
        let contracts = Config.shared.config(for: evmChain).swapWhitelistContracts
        guard contracts.contains(spender) else {
            throw AnyError("Not whitelisted spender \(spender)")
        }
        return spender
    }

    init(
        provider: GemAPISwapService = GemAPIService(),
        nodeProvider: NodeURLFetchable
    ) {
        self.provider = provider
        self.nodeProvider = nodeProvider
    }
    
    func getQuote(request: SwapQuoteRequest) async throws -> SwapQuoteResult {
        return try await provider.getSwap(request: request)
    }
    
    func getAllowance(chain: Chain, contract: String, owner: String, spender: String) async throws -> BigInt {
        let service = EthereumSwapService(
            chain: try EVMChain(from: chain),
            provider: ProviderEvmFactory.create(with: nodeProvider.node(for: chain))
        )
        return try await service.getAllowance(contract: contract, owner: owner, spender: spender)
    }
}
