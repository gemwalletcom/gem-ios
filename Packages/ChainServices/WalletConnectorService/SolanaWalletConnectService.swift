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
        switch WalletConnectionMethods(rawValue: request.method)?.blockchainMethod {
        case .solana(let method): try await handle(method: method, request: request)
        default: throw WalletConnectorServiceError.unresolvedMethod(request.method)
        }
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
        case .signAllTransactions: try await signAllTransactions(request: request)
        }
    }
}

// MARK: - Private Methods

extension SolanaWalletConnectService {
    private func solanaSignTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let transaction = try request.params.get(WCSolanaTransaction.self)
        let signature = try await signer.signTransaction(
            sessionId: request.topic,
            chain: .solana,
            transaction: .solana(transaction.transaction, .signature)
        )
        let result = WCSolanaSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }

    private func solanaSendTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let transaction = try request.params.get(WCSolanaTransaction.self)
        let transactionId = try await signer.sendTransaction(
            sessionId: request.topic,
            chain: .solana,
            transaction: .solana(transaction.transaction, .encodedTransaction)
        )
        return .response(AnyCodable(transactionId))
    }

    private func solanaSignMessage(request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get(WCSolanaSignMessage.self)
        let data = Data(params.message.utf8)
        let message = SignMessage(signType: .base58, data: data)
        let signature = try await signer.signMessage(sessionId: request.topic, chain: .solana, message: message)
        let result = WCSolanaSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }

    private func signAllTransactions(request: WalletConnectSign.Request) async throws -> RPCResult {
        let transactions = try request.params.get(WCSolanaTransactions.self).transactions
        guard let transaction = transactions.first else {
            throw AnyError("Only support single transaction. Will support more in the future")
        }
        let signature = try await signer.signTransaction(
            sessionId: request.topic,
            chain: .solana,
            transaction: .solana(transaction, .encodedTransaction)
        )
        return .response(AnyCodable(WCSolanaTransactions(transactions: [signature])))
    }
}
