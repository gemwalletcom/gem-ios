/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct FiatQuote: Codable, Sendable, Hashable {
	public let provider: FiatProvider
	public let type: FiatTransactionType
	public let fiatAmount: Double
	public let fiatCurrency: String
	public let cryptoAmount: Double
	public let redirectUrl: String

	public init(provider: FiatProvider, type: FiatTransactionType, fiatAmount: Double, fiatCurrency: String, cryptoAmount: Double, redirectUrl: String) {
		self.provider = provider
		self.type = type
		self.fiatAmount = fiatAmount
		self.fiatCurrency = fiatCurrency
		self.cryptoAmount = cryptoAmount
		self.redirectUrl = redirectUrl
	}
}

public struct FiatQuotes: Codable, Sendable {
	public let quotes: [FiatQuote]

	public init(quotes: [FiatQuote]) {
		self.quotes = quotes
	}
}
