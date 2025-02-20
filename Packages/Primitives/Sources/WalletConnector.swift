/*
 Generated by typeshare 1.12.0
 */

import Foundation

public enum SignDigestType: String, Codable, Sendable {
	case sign
	case eip191
	case eip712
	case base58
}

public struct SignMessage: Codable, Sendable {
	public let type: SignDigestType
	public let data: Data

	public init(type: SignDigestType, data: Data) {
		self.type = type
		self.data = data
	}
}

public enum WalletConnectionState: String, Codable, Hashable, Sendable {
	case started
	case active
	case expired
}

public struct WalletConnectionSessionAppMetadata: Codable, Equatable, Hashable, Sendable {
	public let name: String
	public let description: String
	public let url: String
	public let icon: String
	public let redirectNative: String?
	public let redirectUniversal: String?

	public init(name: String, description: String, url: String, icon: String, redirectNative: String?, redirectUniversal: String?) {
		self.name = name
		self.description = description
		self.url = url
		self.icon = icon
		self.redirectNative = redirectNative
		self.redirectUniversal = redirectUniversal
	}
}

public struct WalletConnectionSession: Codable, Equatable, Hashable, Sendable {
	public let id: String
	public let sessionId: String
	public let state: WalletConnectionState
	public let chains: [Chain]
	public let createdAt: Date
	public let expireAt: Date
	public let metadata: WalletConnectionSessionAppMetadata

	public init(id: String, sessionId: String, state: WalletConnectionState, chains: [Chain], createdAt: Date, expireAt: Date, metadata: WalletConnectionSessionAppMetadata) {
		self.id = id
		self.sessionId = sessionId
		self.state = state
		self.chains = chains
		self.createdAt = createdAt
		self.expireAt = expireAt
		self.metadata = metadata
	}
}

public struct WalletConnection: Codable, Equatable, Hashable, Sendable {
	public let session: WalletConnectionSession
	public let wallet: Wallet

	public init(session: WalletConnectionSession, wallet: Wallet) {
		self.session = session
		self.wallet = wallet
	}
}

public struct WalletConnectionSessionProposal: Codable, Equatable, Hashable, Sendable {
	public let defaultWallet: Wallet
	public let wallets: [Wallet]
	public let metadata: WalletConnectionSessionAppMetadata

	public init(defaultWallet: Wallet, wallets: [Wallet], metadata: WalletConnectionSessionAppMetadata) {
		self.defaultWallet = defaultWallet
		self.wallets = wallets
		self.metadata = metadata
	}
}

public enum WalletConnectionEvents: String, Codable, CaseIterable, Sendable {
	case connect
	case disconnect
	case accountsChanged
	case chainChanged
}

public enum WalletConnectionMethods: String, Codable, CaseIterable, Sendable {
	case ethChainId = "eth_chainId"
	case ethSign = "eth_sign"
	case personalSign = "personal_sign"
	case ethSignTypedData = "eth_signTypedData"
	case ethSignTypedDataV4 = "eth_signTypedData_v4"
	case ethSignTransaction = "eth_signTransaction"
	case ethSendTransaction = "eth_sendTransaction"
	case ethSendRawTransaction = "eth_sendRawTransaction"
	case walletSwitchEthereumChain = "wallet_switchEthereumChain"
	case walletAddEthereumChain = "wallet_addEthereumChain"
	case solanaSignMessage = "solana_signMessage"
	case solanaSignTransaction = "solana_signTransaction"
	case solanaSignAndSendTransaction = "solana_signAndSendTransaction"
}
