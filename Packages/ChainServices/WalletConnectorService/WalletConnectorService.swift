// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import WalletConnectPairing
@preconcurrency import ReownWalletKit
import Primitives
import struct Gemstone.SignMessage

public final class WalletConnectorService {
    private let interactor = WCConnectionsInteractor()
    private let signer: WalletConnectorSignable
    private let messageTracker = MessageTracker()
    private let serviceFactory: WalletConnectServiceFactory

    public init(signer: WalletConnectorSignable) {
        self.signer = signer
        self.serviceFactory = WalletConnectServiceFactory(signer: signer)
    }
}

// MARK: - WalletConnectorService

extension WalletConnectorService: WalletConnectorServiceable {
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
    }

    public func setup() async {
        Events.instance.setTelemetryEnabled(false)
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                guard let self else { return }
                await self.handleSessions()
            }

            group.addTask { [weak self] in
                guard let self else { return }
                await self.handleSessionProposals()
            }

            group.addTask { [weak self] in
                guard let self else { return }
                await self.handleSessionRequests()
            }
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
        debugLog("sessions \(sessions)")

        for session in sessions {
            try? await WalletKit.instance.disconnect(topic: session.topic)
            // Pairing will disconnect automatically
        }

        let pairings = Pair.instance.getPairings()

        debugLog("pairings \(pairings)")
        for pairing in pairings {
            try? await Pair.instance.disconnect(topic: pairing.topic)
        }

        try await WalletKit.instance.cleanup()
    }
    
    public func updateSessions() {
        updateSessions(interactor.sessions)
    }
}

// MARK: - Private

extension WalletConnectorService {
    private func handleSessions() async {
        for await sessions in interactor.sessionsStream {
            updateSessions(sessions)
        }
    }

    private func handleSessionProposals() async {
        for await proposal in interactor.sessionProposalStream {
            debugLog("Session proposal received: \(proposal)")

            do {
                try await processSession(proposal: proposal.proposal)
            } catch {
                debugLog("Error accepting proposal: \(error)")
                try? await signer.sessionReject(
                    id: proposal.proposal.pairingTopic,
                    error: error
                )
            }
        }
    }

    private func handleSessionRequests() async {
        for await request in interactor.sessionRequestStream {
            do {
                try await handleRequest(request: request.request)
            } catch {
                debugLog("Error handling request: \(error)")
            }
        }
    }

    private func updateSessions(_ sessions: [Session]) {
        debugLog("Received sessions: \(sessions)")
        do {
            try signer.updateSessions(sessions: sessions.map { $0.asSession })
        } catch {
            debugLog("Error updating sessions: \(error)")
        }
    }

    private func handleRequest(request: WalletConnectSign.Request) async throws  {
        let messageId = request.messageId
        
        guard await messageTracker.shouldProcess(messageId) else {
            debugLog("Ignoring duplicate request with ID: \(messageId)")
            try await rejectRequest(request)
            return
        }

        debugLog("handleMethod received: \(request.method) ")
        debugLog("handleMethod received params: \(request.params) ")

        do {
            let service = try serviceFactory.service(for: request.method)
            let response = try await service.handle(request: request)

            debugLog("handleMethod result: \(request.method) \(response)")
            try await WalletKit.instance.respond(topic: request.topic, requestId: request.id, response: response)
        } catch {
            debugLog("handleMethod error: \(error)")
            try await rejectRequest(request)
        }
    }
    
    private func rejectRequest(_ request: WalletConnectSign.Request) async throws {
        try await WalletKit.instance.respond(topic: request.topic, requestId: request.id, response: .error(JSONRPCError(code: 4001, message: "User rejected the request")))
    }


    private func processSession(proposal: Session.Proposal) async throws {
        let messageId = proposal.messageId
        
        guard await messageTracker.shouldProcess(messageId) else {
            debugLog("Ignoring duplicate proposal with ID: \(messageId)")
            return
        }
        
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
}
