/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct CosmosBroadcastResult: Codable {
	public let txhash: String
	public let code: Int32
	public let raw_log: String

	public init(txhash: String, code: Int32, raw_log: String) {
		self.txhash = txhash
		self.code = code
		self.raw_log = raw_log
	}
}

public struct CosmosBroadcastResponse: Codable {
	public let tx_response: CosmosBroadcastResult

	public init(tx_response: CosmosBroadcastResult) {
		self.tx_response = tx_response
	}
}

public struct CosmosTransactionDataResponse: Codable {
	public let txhash: String
	public let code: Int32

	public init(txhash: String, code: Int32) {
		self.txhash = txhash
		self.code = code
	}
}

public struct CosmosTransactionResponse: Codable {
	public let tx_response: CosmosTransactionDataResponse

	public init(tx_response: CosmosTransactionDataResponse) {
		self.tx_response = tx_response
	}
}
