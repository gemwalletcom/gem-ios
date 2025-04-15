/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct TonResult<T: Codable & Sendable>: Codable, Sendable {
	public let result: T

	public init(result: T) {
		self.result = result
	}
}

public struct TonWalletInfo: Codable, Sendable {
	public let seqno: Int32?
	public let last_transaction_id: TonTransactionId

	public init(seqno: Int32?, last_transaction_id: TonTransactionId) {
		self.seqno = seqno
		self.last_transaction_id = last_transaction_id
	}
}
