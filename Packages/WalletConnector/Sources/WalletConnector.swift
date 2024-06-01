// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectPairing
import Web3Wallet
import Combine
import Primitives
 
public class WalletConnector {
    
    private var disposeBag = Set<AnyCancellable>()
    private var interactor = WCConnectionsInteractor()
    
    let signer: WalletConnectorSignable
    
    public init(
        signer: WalletConnectorSignable
    ) {
        self.signer = signer
    }
    
    public func configure() {
        Networking.configure(groupIdentifier: "group.com.gemwallet.ios", projectId: "3bc07cd7179d11ea65335fb9377702b6", socketFactory: DefaultSocketFactory())
        #if DEBUG
        //Networking.instance.setLogging(level: .debug)
        #endif
        
        let metadata = AppMetadata(
            name: "Gem Wallet",
            description: "Gem Web3 Wallet",
            url: "https://gemwallet.com",
            icons: ["https://gemwallet.com/images/gem-logo-256x256.png"], 
            redirect: AppMetadata.Redirect(
                native: "gem://",
                universal: nil
            )
        )
        
        Web3Wallet.configure(metadata: metadata, crypto: DefaultCryptoProvider())
    }
    
    public func addConnectionURI(uri: String) async throws -> String {
        let uri = try WalletConnectURI(uriString: uri)
        try await Pair.instance.pair(uri: uri)
        return uri.topic
    }
    
    public func disconnect(sessionId: String) async throws {
        try await Web3Wallet.instance.disconnect(topic: sessionId)
    }
    
    public func disconnectPairing(pairingId: String) async throws {
        try await Web3Wallet.instance.disconnectPairing(topic: pairingId)
    }
    
    public func disconnect(topic: String) async throws {
        try await Web3Wallet.instance.disconnect(topic: topic)
    }
    
    public func disconnectAll() async throws {
        let sessions = Web3Wallet.instance.getSessions()
        
        NSLog("sessions \(sessions)")
        
        for session in sessions {
            try? await Web3Wallet.instance.disconnect(topic: session.topic)
            try? await Web3Wallet.instance.disconnectPairing(topic: session.pairingTopic)
        }
        
        let pairings = Pair.instance.getPairings()
        
        NSLog("pairings \(pairings)")
        
        for pairing in pairings {
            try? await Pair.instance.disconnect(topic: pairing.topic)
        }
        
        try await Web3Wallet.instance.cleanup()
    }
    
    public func setup() {
        
        interactor.sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { sessions in
                NSLog("wallet connector sessionsPublisher \(sessions)")
                
                do {
                    try self.signer.updateSessions(sessions: sessions.map { $0.asSession })
                } catch {
                    NSLog("wallet connector update sessions error \(error)")
                }
            }
            .store(in: &disposeBag)
        
        interactor.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                NSLog("wallet connector sessionProposalPublisher \(session)")
                Task {
                    do {
                        let result: () = try await self.acceptProposal(proposal: session.proposal)
                        NSLog("wallet connector acceptProposal \(result)")
                    } catch {
                        NSLog("wallet connector acceptProposal error \(error)")
                        
                        try self.signer.sessionReject(id: session.proposal.pairingTopic, error: error)
                    }
                }
                //router.present(proposal: session.proposal, importAccount: importAccount, context: session.context)
            }
            .store(in: &disposeBag)
        
        interactor.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { request, context in
                NSLog("wallet connector sessionRequestPublisher request \(request)")
                NSLog("wallet connector sessionRequestPublisher context \(String(describing: context))")
                Task {
                    do {
                        try await self.handleRequest(request: request)
                    } catch {
                        NSLog("handleRequest error \(error)")
                    }
                }
                //router.present(sessionRequest: request, importAccount: importAccount, sessionContext: context)
            }.store(in: &disposeBag)
        
//        interactor.authRequestPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { result in
//                NSLog("wallet connector authRequestPublisher \(result)")
//                //router.present(request: result.request, importAccount: importAccount, context: result.context)
//            }
//            .store(in: &disposeBag)
    }
    
    func handleRequest(request: WalletConnectSign.Request) async throws  {
        guard let method = WalletConnectionMethods(rawValue: request.method) else {
            throw(AnyError("unresolved method: \(request.method)"))
        }
        guard let chain = try self.signer.getChains().filter({ $0.blockchain == request.chainId }).first else {
            throw(AnyError("unresolved chain: \(request.chainId)"))
        }
        
        NSLog("handleMethod received: \(method) ")
        NSLog("handleMethod received params: \(request.params) ")
        
        do {
            let response = try await self.handleMethod(method: method, chain: chain, request: request)
            NSLog("handleMethod result: \(method) \(response)")
            
            try await Web3Wallet.instance.respond(
                topic: request.topic,
                requestId: request.id,
                response: response
            )
        } catch {
            NSLog("handleMethod error: \(error)")
            
            try await Web3Wallet.instance.respond(
                topic: request.topic,
                requestId: request.id,
                response: .error(JSONRPCError(code: 0, message: "rejected"))
            )
        }
    }
    
    func handleMethod(method: WalletConnectionMethods, chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
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
            return try await walletAddEthereumChain(chain: chain, request: request)
        case  .walletSwitchEthereumChain:
            return try await walletSwitchEthereumChain(chain: chain, request: request)
        case .solanaSignMessage:
            return try await solanaSignMessage(request: request)
        case .solanaSignTransaction:
            return .error(.invalidRequest)
            //return try await solanaSignTransaction(request: request)
        }
    }
    
    func acceptProposal(proposal: Session.Proposal) async throws {
        let wallet = try signer.getWallet()
        let chains = try signer.getChains()
        let accounts = try signer.getAccounts().filter { chains.contains($0.chain) }
        let events = try signer.getEvents()
        let methods = try signer.getMethods()
        let supportedAccounts = accounts.compactMap { $0.blockchain }
        let supportedChains = chains.compactMap { $0.blockchain }
        
        let sessionNamespaces = try AutoNamespaces.build(
            sessionProposal: proposal,
            chains: supportedChains,
            methods: methods.map { $0.rawValue },
            events: events.map { $0.rawValue },
            accounts: supportedAccounts
        )
        let payload = WalletConnectionSessionProposal(
            wallet: wallet,
            accounts: accounts,
            metadata: proposal.proposer.metadata
        )
        let _ = try await signer.sessionApproval(payload: payload)
        let _ = try await Web3Wallet.instance.approve(
            proposalId: proposal.id,
            namespaces: sessionNamespaces,
            sessionProperties: proposal.sessionProperties
        )
        //try await Pair.instance.disconnect(topic: proposal.pairingTopic)
    }
    
    func ethSign(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([String].self)
        let data = Data(hex: params[1])
        let message = SignMessage(type: .eip191, data: data)
        let digest = try await signer.signMessage(sessionId: request.topic, chain: chain,message: message)
        return .response(AnyCodable(digest))
    }
    
    func personalSign(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
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
    
    func ethSignTypedData(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([String].self)
        let data = params[1].data(using: .utf8)!
        let message = SignMessage(type: .eip712, data: data)
        let digest = try await signer.signMessage(sessionId: request.topic, chain: chain, message: message)
        return .response(AnyCodable(digest))
    }

    func signTransaction(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([Primitives.WCEthereumTransaction].self)
        guard let transaction = params.first else {
            throw AnyError("error")
        }
        let transactionId = try await signer.signTransaction(sessionId: request.topic, chain: chain, transaction: .ethereum(transaction))
        return .response(AnyCodable(transactionId))
    }
    
    func sendTransaction(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get([Primitives.WCEthereumTransaction].self)
        guard let transaction = params.first else {
            throw AnyError("error")
        }
        let transactionId = try await signer.sendTransaction(sessionId: request.topic, chain: chain, transaction: .ethereum(transaction))
        return .response(AnyCodable(transactionId))
    }
    
    func sendRawTransaction(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        return .error(.methodNotFound)
    }
    
    func walletAddEthereumChain(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        return .error(.methodNotFound)
    }
    
    func walletSwitchEthereumChain(chain: Chain, request: WalletConnectSign.Request) async throws -> RPCResult {
        //Web3Wallet.instance.update(topic: request.topic, namespaces: [String : SessionNamespace])
        //return .response(AnyCodable(""))
        return .error(.methodNotFound)
    }
    
    // solana
    func solanaSignTransaction(request: WalletConnectSign.Request) async throws -> RPCResult {
        let transaction = try request.params.get(WCSolanaTransaction.self)
        let transactionId = try await signer.sendTransaction(sessionId: request.topic, chain: .solana, transaction: .solana(transaction.transaction))
        return .response(AnyCodable(transactionId))
    }
    
    func solanaSignMessage(request: WalletConnectSign.Request) async throws -> RPCResult {
        let params = try request.params.get(WCSolanaSignMessage.self)
        let data = Data(params.message.utf8)
        let message = SignMessage(type: .base58, data: data)
        let signature = try await signer.signMessage(sessionId: request.topic, chain: .solana, message: message)
        let result = WCSolanaSignMessageResult(signature: signature)
        return .response(AnyCodable(result))
    }
}

extension Chain {
    var blockchain: WalletConnectUtils.Blockchain? {
        if let namespace = namespace, let reference = reference {
            return Blockchain(namespace: namespace, reference: reference)
        }
        return .none
    }
}

extension Session {
    var asSession: Primitives.WalletConnectionSession {
        return WalletConnectionSession(
            id: pairingTopic,
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
