/*
 Generated by typeshare 1.12.0
 */

import Foundation

public struct FiatQuote: Codable, Equatable, Hashable, Sendable {
	public let provider: FiatProvider
	public let type: FiatQuoteType
	public let fiatAmount: Double
	public let fiatCurrency: String
	public let cryptoAmount: Double
	public let cryptoValue: String
	public let redirectUrl: String

	public init(provider: FiatProvider, type: FiatQuoteType, fiatAmount: Double, fiatCurrency: String, cryptoAmount: Double, cryptoValue: String, redirectUrl: String) {
		self.provider = provider
		self.type = type
		self.fiatAmount = fiatAmount
		self.fiatCurrency = fiatCurrency
		self.cryptoAmount = cryptoAmount
		self.cryptoValue = cryptoValue
		self.redirectUrl = redirectUrl
	}
}

public struct FiatQuoteError: Codable, Sendable {
	public let provider: String
	public let error: String

	public init(provider: String, error: String) {
		self.provider = provider
		self.error = error
	}
}

public struct FiatQuotes: Codable, Sendable {
	public let quotes: [FiatQuote]

	public init(quotes: [FiatQuote]) {
		self.quotes = quotes
	}
}
