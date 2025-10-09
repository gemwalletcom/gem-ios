// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectSign
import Primitives

final class WalletConnectServiceFactory: Sendable {
    private let signer: WalletConnectorSignable
    
    init(signer: WalletConnectorSignable) {
        self.signer = signer
    }
    
    func service(for method: String) throws -> any WalletConnectRequestHandleable {
        switch WalletConnectionMethods(rawValue: method)?.blockchainMethod {
        case .ethereum: EthereumWalletConnectService(signer: signer)
        case .solana: SolanaWalletConnectService(signer: signer)
        case nil: throw WalletConnectorServiceError.unresolvedMethod(method)
        }
    }
}
