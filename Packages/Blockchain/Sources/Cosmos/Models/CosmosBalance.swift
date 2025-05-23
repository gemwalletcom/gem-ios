/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct CosmosBalance: Codable, Sendable {
	public let denom: String
	public let amount: String

	public init(denom: String, amount: String) {
		self.denom = denom
		self.amount = amount
	}
}

public struct CosmosBalances: Codable, Sendable {
	public let balances: [CosmosBalance]

	public init(balances: [CosmosBalance]) {
		self.balances = balances
	}
}
