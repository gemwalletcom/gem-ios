/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct AlgorandAccount: Codable, Sendable {
	public let amount: UInt64

	public init(amount: UInt64) {
		self.amount = amount
	}
}

public struct AlgorandTransactionBroadcast: Codable, Sendable {
	public let txId: String

	public init(txId: String) {
		self.txId = txId
	}
}

public struct AlgorandTransactionBroadcastError: Codable, Sendable {
	public let message: String

	public init(message: String) {
		self.message = message
	}
}

public struct AlgorandTransactionParams: Codable, Sendable {
	public let min_fee: Int32
	public let genesis_id: String
	public let genesis_hash: String
	public let last_round: Int32

	enum CodingKeys: String, CodingKey, Codable {
		case min_fee = "min-fee",
			genesis_id = "genesis-id",
			genesis_hash = "genesis-hash",
			last_round = "last-round"
	}

	public init(min_fee: Int32, genesis_id: String, genesis_hash: String, last_round: Int32) {
		self.min_fee = min_fee
		self.genesis_id = genesis_id
		self.genesis_hash = genesis_hash
		self.last_round = last_round
	}
}

public struct AlgorandTransactionStatus: Codable, Sendable {
	public let confirmed_round: Int32

	enum CodingKeys: String, CodingKey, Codable {
		case confirmed_round = "confirmed-round"
	}

	public init(confirmed_round: Int32) {
		self.confirmed_round = confirmed_round
	}
}

public struct AlgorandVersions: Codable, Sendable {
	public let genesis_id: String
	public let genesis_hash: String

	enum CodingKeys: String, CodingKey, Codable {
		case genesis_id = "genesis-id",
			genesis_hash = "genesis-hash"
	}

	public init(genesis_id: String, genesis_hash: String) {
		self.genesis_id = genesis_id
		self.genesis_hash = genesis_hash
	}
}
