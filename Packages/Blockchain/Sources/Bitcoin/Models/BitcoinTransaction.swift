/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct BitcoinTransaction: Codable, Sendable {
	public let blockHeight: Int32

	public init(blockHeight: Int32) {
		self.blockHeight = blockHeight
	}
}

public struct BitcoinTransactionBroacastError: Codable, Sendable {
	public let message: String

	public init(message: String) {
		self.message = message
	}
}

public struct BitcoinTransactionBroacastResult: Codable, Sendable {
	public let error: BitcoinTransactionBroacastError?
	public let result: String?

	public init(error: BitcoinTransactionBroacastError?, result: String?) {
		self.error = error
		self.result = result
	}
}
