// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectSign
import Primitives
import struct Gemstone.SignMessage

final class EthereumWalletConnectService: WalletConnectRequestHandleable {
    private let signer: WalletConnectorSignable
    
    init(signer: WalletConnectorSignable) {
        self.signer = signer
    }
    
    func handle(request: WalletConnectSign.Request) async throws -> RPCResult {
        switch WalletConnectionMethods(rawValue: request.method)?.blockchainMethod {
        case .ethereum(let method):
            guard let chain = signer.allChains.first(where: { $0.blockchain == request.chainId }) else {
                throw WalletConnectorServiceError.unresolvedChainId(request.chainId.absoluteString)
            }
            
            return try await handle(method: method, chain: chain, request: request)
        case .solana, nil:
            throw WalletConnectorServiceError.unresolvedMethod(request.method)
        }
    }
}

// MARK: - Private Methods

private extension EthereumWalletConnectService {
    func handle(
        method: WalletConnectEthereumMethods,
        chain: Chain,
        request: WalletConnectSign.Request
    ) async throws -> RPCResult {
        switch method {
        case .sign: try await ethSign(chain: chain, request: request)
        case .personalSign: try await personalSign(chain: chain, request: request)
        case .signTypedData, .signTypedDataV4: try await ethSignTypedData(chain: chain, request: request)
        case .signTransaction: try await signTransaction(chain: chain, request: request)
        case .sendTransaction: try await sendTransaction(chain: chain, request: request)
        case .sendRawTransaction: try await sendRawTransaction(chain: chain, request: request)
        case .chainId: try chainId()
        case .addChain: walletAddEthereumChain(chain: chain, request: request)
        case .switchChain: walletSwitchEthereumChain(chain: chain, request: request)
        }
    }
}

// MARK: - Private Methods

extension EthereumWalletConnectService {
    private func ethSign(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([String].self)
        let data = Data(hex: params[1])
        let message = SignMessage(signType: .eip191, data: data)
        let digest = try await signer.signMessage(sessionId: request.topic, chain: chain, message: message)
        return .response(AnyCodable(digest))
    }

    private func personalSign(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([String].self)
        let param = params[0]
        let data: Data = {
            let hex = Data(hex: param)
            if hex.isEmpty {
                return Data(param.utf8)
            }
            return hex
        }()
        let message = SignMessage(signType: .eip191, data: data)
        let digest = try await signer.signMessage(sessionId: request.topic, chain: chain, message: message)
        return .response(AnyCodable(digest))
    }

    private func ethSignTypedData(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([String].self)
        guard let data = params[1].data(using: .utf8) else {
            throw WalletConnectorServiceError.wrongSignParameters
        }
        let message = SignMessage(signType: .eip712, data: data)
        let digest = try await signer.signMessage(sessionId: request.topic, chain: chain, message: message)
        return .response(AnyCodable(digest))
    }

    private func signTransaction(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([Primitives.WCEthereumTransaction].self)
        guard let transaction = params.first else {
            throw WalletConnectorServiceError.wrongSignParameters
        }
        let transactionId = try await signer.signTransaction(sessionId: request.topic, chain: chain, transaction: .ethereum(transaction))
        return .response(AnyCodable(transactionId))
    }

    private func sendTransaction(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([Primitives.WCEthereumTransaction].self)
        guard let transaction = params.first else {
            throw WalletConnectorServiceError.wrongSendParameters
        }
        let transactionId = try await signer.sendTransaction(sessionId: request.topic, chain: chain, transaction: .ethereum(transaction))
        return .response(AnyCodable(transactionId))
    }

    private func walletAddEthereumChain(chain: Chain, request: WalletConnectSign.Request) -> RPCResult {
        .response(AnyCodable.null())
    }

    private func walletSwitchEthereumChain(chain: Chain, request: WalletConnectSign.Request) -> RPCResult {
        .response(AnyCodable.null())
    }
        
    // TODO: - Implement methods
    private func chainId() throws -> RPCResult {
        .error(.methodNotFound)
    }

    private func sendRawTransaction(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        .error(.methodNotFound)
    }
}

