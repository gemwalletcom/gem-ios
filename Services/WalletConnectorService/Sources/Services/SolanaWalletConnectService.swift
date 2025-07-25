// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectSign
import Primitives
import struct Gemstone.SignMessage

final class SolanaWalletConnectService: WalletConnectRequestHandleable {
    private let signer: WalletConnectorSignable
    
    init(signer: WalletConnectorSignable) {
        self.signer = signer
    }
    
    func handle(request: WalletConnectSign.Request) async throws -> RPCResult {
        guard let method = WalletConnectionMethods(rawValue: request.method)?.blockchainMethod?.solana else {
            throw WalletConnectorServiceError.unresolvedMethod(request.method)
        }
        
        return try await handle(method: method, request: request)
    }
}

// MARK: - Private Methods

private extension SolanaWalletConnectService {
    func handle(
        method: WalletConnectSolanaMethods,
        request: WalletConnectSign.Request
    ) async throws -> RPCResult {
        switch method {
        case .signMessage: try await solanaSignMessage(request: request)
        case .signTransaction: try await solanaSignTransaction(request: request)
        case .signAndSendTransaction: try await solanaSendTransaction(request: request)
        case .signAllTransactions: try signAllTransactions()
        }
    }
}

// MARK: - Private Methods

extension SolanaWalletConnectService {
    private func solanaSignTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let tx = try request.params.get(WCSolanaTransaction.self)
        let signature = try await signer.signTransaction(sessionId: request.topic, chain: .solana, transaction: .solana(tx.transaction))
        let result = WCSolanaSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }

    private func solanaSendTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let tx = try request.params.get(WCSolanaTransaction.self)
        let txId = try await signer.sendTransaction(sessionId: request.topic, chain: .solana, transaction: .solana(tx.transaction))
        return .response(AnyCodable(txId))
    }

    private func solanaSignMessage(request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get(WCSolanaSignMessage.self)
        let data = Data(params.message.utf8)
        let message = SignMessage(signType: .base58, data: data)
        let signature = try await signer.signMessage(sessionId: request.topic, chain: .solana, message: message)
        let result = WCSolanaSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }
    
    // TODO: - Implement methods
    private func signAllTransactions() throws -> RPCResult {
        throw AnyError.notImplemented
    }
}
