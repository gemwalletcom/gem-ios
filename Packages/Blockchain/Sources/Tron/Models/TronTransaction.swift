/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct TronReceipt: Codable {
	public let result: String?

	public init(result: String?) {
		self.result = result
	}
}

public struct TronTransactionContractRef: Codable {
	public let contractRet: String

	public init(contractRet: String) {
		self.contractRet = contractRet
	}
}

public struct TronTransaction: Codable {
	public let ret: [TronTransactionContractRef]

	public init(ret: [TronTransactionContractRef]) {
		self.ret = ret
	}
}

public struct TronTransactionBroadcast: Codable {
	public let result: Bool
	public let txid: String

	public init(result: Bool, txid: String) {
		self.result = result
		self.txid = txid
	}
}

public struct TronTransactionBroadcastError: Codable {
	public let message: String

	public init(message: String) {
		self.message = message
	}
}

public struct TronTransactionReceipt: Codable {
	public let blockNumber: Int32
	public let fee: Int32?
	public let result: String?
	public let receipt: TronReceipt?

	public init(blockNumber: Int32, fee: Int32?, result: String?, receipt: TronReceipt?) {
		self.blockNumber = blockNumber
		self.fee = fee
		self.result = result
		self.receipt = receipt
	}
}
