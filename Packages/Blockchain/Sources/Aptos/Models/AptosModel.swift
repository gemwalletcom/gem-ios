/*
 Generated by typeshare 1.9.2
 */

import Foundation

public struct AptosResource<T: Codable>: Codable {
	public let type: String
	public let data: T

	public init(type: String, data: T) {
		self.type = type
		self.data = data
	}
}

public struct AptosResourceCoin: Codable {
	public let value: String

	public init(value: String) {
		self.value = value
	}
}

public struct AptosResourceBalance: Codable {
	public let coin: AptosResourceCoin

	public init(coin: AptosResourceCoin) {
		self.coin = coin
	}
}

public struct AptosAccount: Codable {
	public let sequence_number: String

	public init(sequence_number: String) {
		self.sequence_number = sequence_number
	}
}

public struct AptosTransaction: Codable {
	public let success: Bool

	public init(success: Bool) {
		self.success = success
	}
}

public struct AptosTransactionBroacast: Codable {
	public let hash: String

	public init(hash: String) {
		self.hash = hash
	}
}

public struct AptosGasFee: Codable {
	public let gas_estimate: Int32
	public let prioritized_gas_estimate: Int32

	public init(gas_estimate: Int32, prioritized_gas_estimate: Int32) {
		self.gas_estimate = gas_estimate
		self.prioritized_gas_estimate = prioritized_gas_estimate
	}
}

public struct AptosLedger: Codable {
	public let chain_id: Int32
	public let ledger_version: String

	public init(chain_id: Int32, ledger_version: String) {
		self.chain_id = chain_id
		self.ledger_version = ledger_version
	}
}
