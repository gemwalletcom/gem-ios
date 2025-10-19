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
        let data = Data(params.message.utf8)
        let message = SignMessage(signType: .sign, data: data)
        let signature = try await signer.signMessage(sessionId: request.topic, chain: .sui, message: message)
        let result = WCSuiSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }

    private func suiSignTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let tx = try request.params.get(WCSuiTransaction.self)
        let signature = try await signer.signTransaction(
            sessionId: request.topic,
            chain: .sui,
            transaction: .sui(tx.transaction, .signature)
        )
        let result = WCSuiSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }

    private func suiSignAndExecuteTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let tx = try request.params.get(WCSuiTransaction.self)
        let txId = try await signer.sendTransaction(
            sessionId: request.topic,
            chain: .sui,
            transaction: .sui(tx.transaction, .encodedTransaction)
        )
        return .response(AnyCodable(txId))
    }
}
