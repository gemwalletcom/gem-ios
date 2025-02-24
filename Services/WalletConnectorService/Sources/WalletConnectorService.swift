// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectPairing
import ReownWalletKit
import Primitives

public final class WalletConnectorService: Sendable {
    private let interactor = WCConnectionsInteractor()
    private let signer: WalletConnectorSignable

    public init(signer: WalletConnectorSignable) {
        self.signer = signer
    }
}

// MARK: - Public

extension WalletConnectorService {
    public func configure() throws {
        Networking.configure(
            groupIdentifier: "group.com.gemwallet.ios",
            projectId: "3bc07cd7179d11ea65335fb9377702b6",
            socketFactory: DefaultSocketFactory()
        )

        WalletKit.configure(
            metadata: AppMetadata(
                name: "Gem Wallet",
                description: "Gem Web3 Wallet",
                url: "https://gemwallet.com",
                icons: ["https://gemwallet.com/images/gem-logo-256x256.png"],
                redirect: try AppMetadata.Redirect(
                    native: "gem://",
                    universal: .none
                )
            ),
            crypto: DefaultCryptoProvider()
        )
        Events.instance.setTelemetryEnabled(false)
    }

    public func setup() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.handleSessions() }
            group.addTask { await self.handleSessionProposals() }
            group.addTask { await self.handleSessionRequests() }
        }
    }

    public func pair(uri: String) async throws {
        let uri = try WalletConnectURI(uriString: uri)
        try await Pair.instance.pair(uri: uri)
    }

    public func disconnect(sessionId: String) async throws {
        try await WalletKit.instance.disconnect(topic: sessionId)
    }

    public func disconnectAll() async throws {
        let sessions = WalletKit.instance.getSessions()
        NSLog("sessions \(sessions)")

        for session in sessions {
            try? await WalletKit.instance.disconnect(topic: session.topic)
            // Pairing will disconnect automatically
        }

        let pairings = Pair.instance.getPairings()

        NSLog("pairings \(pairings)")
        for pairing in pairings {
            try? await Pair.instance.disconnect(topic: pairing.topic)
        }

        try await WalletKit.instance.cleanup()
    }
}

// MARK: - Private

extension WalletConnectorService {
    private func handleSessions() async {
        for await sessions in interactor.sessionsStream {
            NSLog("Received sessions: \(sessions)")
            do {
                try signer.updateSessions(sessions: sessions.map { $0.asSession })
            } catch {
                NSLog("Error updating sessions: \(error)")
            }
        }
    }

    private func handleSessionProposals() async {
        for await proposal in interactor.sessionProposalStream {
            NSLog("Session proposal received: \(proposal)")
            Task {
                do {
                    try await processSession(proposal: proposal.proposal)
                } catch {
                    NSLog("Error accepting proposal: \(error)")
                    try await signer.sessionReject(id: proposal.proposal.pairingTopic, error: error)
                }
            }
        }
    }

    private func handleSessionRequests() async {
        for await request in interactor.sessionRequestStream {
            Task {
                do {
                    try await handleRequest(request: request.request)
                } catch {
                    NSLog("Error handling request: \(error)")
                }
            }
        }
    }

    private func handleRequest(request: WalletConnectSign.Request) async throws  {
        guard let method = WalletConnectionMethods(rawValue: request.method) else {
            throw WalletConnectorServiceError.unresolvedMethod(request.method)
        }
        guard let chain = signer.allChains.filter({ $0.blockchain == request.chainId }).first else {
            throw WalletConnectorServiceError.unresolvedChainId(request.chainId.absoluteString)
        }

        NSLog("handleMethod received: \(method) ")
        NSLog("handleMethod received params: \(request.params) ")

        do {
            let response = try await handleMethod(method: method, chain: chain, request: request)
            NSLog("handleMethod result: \(method) \(response)")
            try await WalletKit.instance.respond(topic: request.topic, requestId: request.id, response: response)
        } catch {
            NSLog("handleMethod error: \(error)")
            try await WalletKit.instance.respond(topic: request.topic ,requestId: request.id, response: .error(JSONRPCError(code: 0, message: "rejected")))
        }
    }

    private func handleMethod(method: WalletConnectionMethods, chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        switch method {
        case .ethSign:
            return try await self.ethSign(chain: chain, request: request)
        case .personalSign:
            return try await self.personalSign(chain: chain, request: request)
        case .ethSignTypedData, .ethSignTypedDataV4:
            return try await self.ethSignTypedData(chain: chain, request: request)
        case .ethSignTransaction:
            return try await self.signTransaction(chain: chain, request: request)
        case .ethSendTransaction:
            return try await self.sendTransaction(chain: chain, request: request)
        case .ethSendRawTransaction:
            return try await self.sendRawTransaction(chain: chain, request: request)
        case .ethChainId:
            return .error(.methodNotFound)
        case .walletAddEthereumChain:
            return walletAddEthereumChain(chain: chain, request: request)
        case  .walletSwitchEthereumChain:
            return walletSwitchEthereumChain(chain: chain, request: request)
        case .solanaSignMessage:
            return try await solanaSignMessage(request: request)
        case .solanaSignTransaction:
            return try await solanaSignTransaction(request: request)
        case .solanaSignAndSendTransaction:
            return try await solanaSendTransaction(request: request)
        }
    }

    private func processSession(proposal: Session.Proposal) async throws {
        let wallets = try signer.getWallets(for: proposal)
        let currentWalletId = try signer.getCurrentWallet().walletId

        guard let preselectedWallet = wallets.first(where: { $0.walletId ==  currentWalletId }) ?? wallets.first else {
            throw WalletConnectorServiceError.walletsUnsupported
        }
        let payload = WalletConnectionSessionProposal(
            defaultWallet: preselectedWallet,
            wallets: wallets,
            metadata: proposal.proposer.metadata
        )

        let payloadTopic = WCPairingProposal(pairingId: proposal.pairingTopic, proposal: payload)
        let approvedWalletId = try await signer.sessionApproval(payload: payloadTopic)
        let selectedWallet = try signer.getWallet(id: approvedWalletId)

        let session = try await acceptProposal(proposal: proposal, wallet: selectedWallet)
        try signer.addConnection(connection: WalletConnection(session: session.asSession, wallet: selectedWallet))
    }

    private func acceptProposal(proposal: Session.Proposal, wallet: Wallet) async throws -> Session {
        let chains = signer.getChains(wallet: wallet)
        let accounts = signer.getAccounts(wallet: wallet, chains: chains)
        let events = signer.getEvents()
        let methods = signer.getMethods()
        let supportedAccounts = accounts.compactMap { $0.blockchain }
        let supportedChains = chains.compactMap { $0.blockchain }

        let sessionNamespaces = try AutoNamespaces.build(
            sessionProposal: proposal,
            chains: supportedChains,
            methods: methods.map { $0.rawValue },
            events: events.map { $0.rawValue },
            accounts: supportedAccounts
        )
        return try await WalletKit.instance.approve(
            proposalId: proposal.id,
            namespaces: sessionNamespaces,
            sessionProperties: proposal.sessionProperties
        )
    }
    
    // MARK: - Ethereum methods

    private func ethSign(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([String].self)
        let data = Data(hex: params[1])
        let message = SignMessage(type: .eip191, data: data)
        let digest = try await signer.signMessage(sessionId: request.topic, chain: chain,message: message)
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
        let message = SignMessage(type: .eip191, data: data)
        let digest = try await signer.signMessage(sessionId: request.topic, chain: chain, message: message)
        return .response(AnyCodable(digest))
    }

    private func ethSignTypedData(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([String].self)
        let data = params[1].data(using: .utf8)!
        let message = SignMessage(type: .eip712, data: data)
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

    private func sendRawTransaction(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        return .error(.methodNotFound)
    }

    private func walletAddEthereumChain(chain: Chain, request: WalletConnectSign.Request) -> RPCResult {
        return .response(AnyCodable(any: NSNull()))
    }

    private func walletSwitchEthereumChain(chain: Chain, request: WalletConnectSign.Request) -> RPCResult {
        return .response(AnyCodable(any: NSNull()))
    }

    // MARK: - Solana methods
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
        let message = SignMessage(type: .base58, data: data)
        let signature = try await signer.signMessage(sessionId: request.topic, chain: .solana, message: message)
        let result = WCSolanaSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }
}

// MARK: - Models extensions

extension Session {
    var asSession: Primitives.WalletConnectionSession {
        WalletConnectionSession(
            sessionId: topic,
            state: .active,
            chains: [],
            createdAt: .now,
            expireAt: expiryDate,
            metadata: peer.metadata
        )
    }
}

extension AppMetadata {
    var metadata: WalletConnectionSessionAppMetadata {
        let icon = icons.filter { $0.contains(".png") }.first ?? icons.first
        return WalletConnectionSessionAppMetadata(
            name: name,
            description: description,
            url: url,
            icon: icon ?? .empty,
            redirectNative: redirect?.native,
            redirectUniversal: redirect?.universal
        )
    }
}

extension Primitives.Account {
    var blockchain: WalletConnectUtils.Account? {
        if let blockchain = chain.blockchain {
            return Account(blockchain: blockchain, address: address)
        }
        return .none
    }
}
