/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct UTXO: Codable {
	public let transaction_id: String
	public let vout: Int32
	public let value: String

	public init(transaction_id: String, vout: Int32, value: String) {
		self.transaction_id = transaction_id
		self.vout = vout
		self.value = value
	}
}
