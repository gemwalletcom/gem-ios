/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct SolanaBalance: Codable {
	public let value: Int

	public init(value: Int) {
		self.value = value
	}
}

public struct SolanaBalanceValue: Codable {
	public let amount: String

	public init(amount: String) {
		self.amount = amount
	}
}
