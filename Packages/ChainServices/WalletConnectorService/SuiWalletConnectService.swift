// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectSign
import Primitives
import struct Gemstone.SignMessage

final class SuiWalletConnectService: WalletConnectRequestHandleable {
    private let signer: WalletConnectorSignable

    init(signer: WalletConnectorSignable) {
        self.signer = signer
    }

    func handle(request: WalletConnectSign.Request) async throws -> RPCResult {
        switch WalletConnectionMethods(rawValue: request.method)?.blockchainMethod {
        case .sui(let method): try await handle(method: method, request: request)
        case .ethereum, .solana, nil: throw WalletConnectorServiceError.unresolvedMethod(request.method)
        }
    }
}

extension SuiWalletConnectService {
    private func handle(
        method: WalletConnectSuiMethods,
        request: WalletConnectSign.Request
    ) async throws -> RPCResult {
        switch method {
        case .signPersonalMessage: try await suiSignMessage(request: request)
        case .signTransaction: try await suiSignTransaction(request: request)
        case .signAndExecuteTransaction: try await suiSignAndExecuteTransaction(request: request)
        }
    }
}

extension SuiWalletConnectService {
    private func suiSignMessage(request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get(WCSuiSignMessage.self)
        let data = Data(base64Encoded: params.message) ?? Data(params.message.utf8)
        let message = SignMessage(signType: .suiPersonalMessage, data: data)
        let signature = try await signer.signMessage(sessionId: request.topic, chain: .sui, message: message)
        let result = WCSuiSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }

    private func suiSignTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let tx = try request.params.get(WCSuiTransaction.self)
        let signedPayload = try await signer.signTransaction(
            sessionId: request.topic,
            chain: .sui,
            transaction: .sui(tx.transaction, .signature)
        )
        let parts = signedPayload.split(separator: "_", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else {
            throw WalletConnectorServiceError.wrongSignParameters
        }
        let result = WCSuiSignTransactionResult(
            signature: String(parts[1]),
            transactionBytes: String(parts[0])
        )
        return .response(AnyCodable(result))
    }

    private func suiSignAndExecuteTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let tx = try request.params.get(WCSuiTransaction.self)
        let txId = try await signer.sendTransaction(
            sessionId: request.topic,
            chain: .sui,
            transaction: .sui(tx.transaction, .encodedTransaction)
        )
        let result = WCSuiSignAndExecuteTransactionResult(digest: txId)
        return .response(AnyCodable(result))
    }
}
