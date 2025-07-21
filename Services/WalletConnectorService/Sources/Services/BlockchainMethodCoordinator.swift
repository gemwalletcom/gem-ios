// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectSign
import Primitives

final class BlockchainMethodCoordinator: Sendable {
    private let ethereumService: EthereumWalletConnectorService
    private let solanaService: SolanaWalletConnectorService
    
    init(signer: WalletConnectorSignable) {
        self.ethereumService = EthereumWalletConnectorService(signer: signer)
        self.solanaService = SolanaWalletConnectorService(signer: signer)
    }
    
    func handleMethod(
        method: WalletConnectionMethods,
        chain: Chain,
        request: WalletConnectSign.Request
    ) async throws -> RPCResult {
        switch method.blockchainMethod {
        case .ethereum(let ethereumMethod):
            return try await ethereumService.handle(
                method: ethereumMethod,
                chain: chain,
                request: request
            )
        case .solana(let solanaMethod):
            return try await solanaService.handle(
                method: solanaMethod,
                request: request
            )
        case nil:
            throw WalletConnectorServiceError.unresolvedMethod(method.rawValue)
        }
    }
}
