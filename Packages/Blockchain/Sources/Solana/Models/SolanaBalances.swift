/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct SolanaBalance: Codable, Sendable {
	public let value: UInt64

	public init(value: UInt64) {
		self.value = value
	}
}

public struct SolanaBalanceValue: Codable, Sendable {
	public let amount: String

	public init(amount: String) {
		self.amount = amount
	}
}
