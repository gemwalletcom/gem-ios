/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct PolkadotAccountBalance: Codable, Sendable {
	public let free: String
	public let reserved: String
	public let nonce: String

	public init(free: String, reserved: String, nonce: String) {
		self.free = free
		self.reserved = reserved
		self.nonce = nonce
	}
}

public struct PolkadotExtrinsic: Codable, Sendable {
	public let hash: String
	public let success: Bool

	public init(hash: String, success: Bool) {
		self.hash = hash
		self.success = success
	}
}

public struct PolkadotBlock: Codable, Sendable {
	public let number: String
	public let extrinsics: [PolkadotExtrinsic]

	public init(number: String, extrinsics: [PolkadotExtrinsic]) {
		self.number = number
		self.extrinsics = extrinsics
	}
}

public struct PolkadotEstimateFee: Codable, Sendable {
	public let partialFee: String

	public init(partialFee: String) {
		self.partialFee = partialFee
	}
}

public struct PolkadotNodeVersion: Codable, Sendable {
	public let chain: String

	public init(chain: String) {
		self.chain = chain
	}
}

public struct PolkadotTransactionBroadcast: Codable, Sendable {
	public let hash: String

	public init(hash: String) {
		self.hash = hash
	}
}

public struct PolkadotTransactionBroadcastError: Codable, Sendable {
	public let error: String
	public let cause: String

	public init(error: String, cause: String) {
		self.error = error
		self.cause = cause
	}
}

public struct PolkadotTransactionMaterialBlock: Codable, Sendable {
	public let height: String
	public let hash: String

	public init(height: String, hash: String) {
		self.height = height
		self.hash = hash
	}
}

public struct PolkadotTransactionMaterial: Codable, Sendable {
	public let at: PolkadotTransactionMaterialBlock
	public let genesisHash: String
	public let chainName: String
	public let specName: String
	public let specVersion: String
	public let txVersion: String

	public init(at: PolkadotTransactionMaterialBlock, genesisHash: String, chainName: String, specName: String, specVersion: String, txVersion: String) {
		self.at = at
		self.genesisHash = genesisHash
		self.chainName = chainName
		self.specName = specName
		self.specVersion = specVersion
		self.txVersion = txVersion
	}
}

public struct PolkadotTransactionPayload: Codable, Sendable {
	public let tx: String

	public init(tx: String) {
		self.tx = tx
	}
}