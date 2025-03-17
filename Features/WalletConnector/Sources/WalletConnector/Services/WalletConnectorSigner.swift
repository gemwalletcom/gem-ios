// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectorService
import Primitives
import Store
import Preferences
import BigInt
import class Gemstone.Config
import WalletConnectSign
import WalletSessionService

public final class WalletConnectorSigner: WalletConnectorSignable {
    private let connectionsStore: ConnectionsStore
    private let walletConnectorInteractor: any WalletConnectorInteractable
    private let walletSessionService: any WalletSessionManageable

    public init(
        connectionsStore: ConnectionsStore,
        walletStore: WalletStore,
        preferences: ObservablePreferences,
        walletConnectorInteractor: any WalletConnectorInteractable
    ) {
        self.connectionsStore = connectionsStore
        self.walletConnectorInteractor = walletConnectorInteractor
        self.walletSessionService = WalletSessionService(walletStore: walletStore, preferences: preferences)
    }

    public var allChains: [Primitives.Chain]  {
        Config.shared.getWalletConnectConfig().chains.compactMap { Chain(rawValue: $0) }
    }

    public func getCurrentWallet() throws -> Wallet {
        try walletSessionService.getCurrentWallet()
    }

    public func getWallet(id: WalletId) throws -> Wallet {
        try walletSessionService.getWallet(walletId: id)
    }

    public func getChains(wallet: Wallet) -> [Primitives.Chain] {
        wallet.accounts.map { $0.chain }.asSet().intersection(allChains).asArray()
    }

    public func getAccounts(wallet: Wallet, chains: [Primitives.Chain]) -> [Primitives.Account] {
        wallet.accounts.filter { chains.contains($0.chain) }
    }
    
    public func getWallets(for proposal: Session.Proposal) throws -> [Wallet] {
        let wallets = try walletSessionService.getWallets().filter { !$0.isViewOnly }
        let blockchains = (proposal.requiredBlockchains + proposal.optionalBlockchains).asSet()
        
        return wallets.filter {
            $0.accounts.compactMap { $0.chain.blockchain }.contains {
                blockchains.contains($0)
            }
        }
    }

    public func getEvents() -> [WalletConnectionEvents] {
        WalletConnectionEvents.allCases
    }
    
    public func getMethods() -> [WalletConnectionMethods] {
        WalletConnectionMethods.allCases
    }

    public func sessionApproval(payload: WCPairingProposal) async throws -> WalletId {
        try await walletConnectorInteractor.sessionApproval(payload: payload)
    }
    
    public func signMessage(sessionId: String, chain: Chain, message: SignMessage) async throws -> String {
        let session = try connectionsStore.getConnection(id: sessionId)
        let payload = SignMessagePayload(chain: chain, session: session.session, wallet: session.wallet, message: message)
        return try await walletConnectorInteractor.signMessage(payload: payload)
    }
    
    public func updateSessions(sessions: [WalletConnectionSession]) throws {
        if sessions.isEmpty {
            try? connectionsStore.deleteAll()
        } else {
            let newSessionIds = sessions.map { $0.id }.asSet()
            let sessionIds = try connectionsStore.getSessions().filter { $0.state == .active }.map { $0.id }.asSet()
            let deleteIds = sessionIds.subtracting(newSessionIds).asArray()

            try? connectionsStore.delete(ids: deleteIds)

            for session in sessions {
                try? connectionsStore.updateConnectionSession(session)
            }
        }
    }
    
    public func sessionReject(id: String, error: any Error) async throws {
        try connectionsStore.delete(ids: [id])
        await walletConnectorInteractor.sessionReject(error: error)
    }
    
    public func signTransaction(sessionId: String, chain: Chain, transaction: WalletConnectorTransaction) async throws -> String {
        let session = try connectionsStore.getConnection(id: sessionId)

        // TODO: - review why not get wallet from session (session.wallet)
        let wallet = try getWallet(id: session.wallet.walletId)

        switch transaction {
        case .ethereum: throw AnyError("Not supported yet")
        case .solana(let tx):
            let transferData = TransferData(
                type: .generic(asset: chain.asset, metadata: session.session.metadata, extra: TransferDataExtra(data: tx.data(using: .utf8), outputType: .signature)),
                recipientData: RecipientData(
                    recipient: Recipient(name: .none, address: "", memo: .none),
                    amount: .none
                ),
                value: .zero,
                canChangeValue: false
            )
            return try await walletConnectorInteractor.signTransaction(transferData: WCTransferData(tranferData: transferData, wallet: wallet))
        }
    }
    
    public func sendTransaction(sessionId: String, chain: Chain, transaction: WalletConnectorTransaction) async throws -> String {
        let session = try connectionsStore.getConnection(id: sessionId)
        // TODO: - review why not get wallet from session (session.wallet)
        let wallet = try getWallet(id: session.wallet.walletId)

        switch transaction {
        case .ethereum(let transaction):
            let address = transaction.to
            let value = try BigInt.fromHex(transaction.value ?? .zero)
            let gasLimit: BigInt? = {
                if let value = transaction.gasLimit {
                    return BigInt(hex: value)
                } else if let gas = transaction.gas {
                    return BigInt(hex: gas)
                }
                return .none
            }()
            
            let gasPrice: GasPriceType? = {
                if let maxFeePerGas = transaction.maxFeePerGas,
                   let maxPriorityFeePerGas = transaction.maxPriorityFeePerGas,
                   let maxFeePerGasBigInt = BigInt(hex: maxFeePerGas),
                   let maxPriorityFeePerGasBigInt = BigInt(hex: maxPriorityFeePerGas)
                {
                    return .eip1559(gasPrice: maxFeePerGasBigInt, priorityFee: maxPriorityFeePerGasBigInt)
                }
                return .none
            }()
            let data: Data? = {
                if let data = transaction.data {
                    return Data(hex: data)
                }
                return .none
            }()
            
            let transferData = TransferData(
                type: .generic(asset: chain.asset, metadata: session.session.metadata, extra: TransferDataExtra(
                    gasLimit: gasLimit,
                    gasPrice: gasPrice,
                    data: data
                )),
                recipientData: RecipientData(
                    recipient: Recipient(name: .none, address: address, memo: .none),
                    amount: .none
                ),
                value: value,
                canChangeValue: false
            )

            return try await walletConnectorInteractor.sendTransaction(transferData: WCTransferData(tranferData: transferData, wallet: wallet))
        case .solana(let tx):
            let transferData = TransferData(
                type: .generic(asset: chain.asset, metadata: session.session.metadata, extra: TransferDataExtra(data: tx.data(using: .utf8))),
                recipientData: RecipientData(
                    recipient: Recipient(name: .none, address: "", memo: .none),
                    amount: .none
                ),
                value: .zero,
                canChangeValue: false
            )
            return try await walletConnectorInteractor.sendTransaction(transferData: WCTransferData(tranferData: transferData, wallet: wallet))
        }
    }
    
    public func sendRawTransaction(sessionId: String, chain: Chain, transaction: String) async throws -> String {
        throw AnyError("Not supported yet")
    }
    
    public func addConnection(connection: WalletConnection) throws {
        try connectionsStore.addConnection(connection)
    }
}

extension Session.Proposal {
    var requiredBlockchains: [Blockchain] {
        requiredNamespaces.values.compactMap { namespace in
            namespace.chains
        }
        .reduce([], +)
        .asSet()
        .asArray()
    }
    
    var optionalBlockchains: [Blockchain] {
        optionalNamespaces?.values.compactMap { namespace in
            namespace.chains
        }
        .reduce([], +)
        .asSet()
        .asArray() ?? []
    }
}
