/*
 Generated by typeshare 1.12.0
 */

import Foundation

public enum PriceAlertDirection: String, Codable, Equatable, Hashable, Sendable {
	case up
	case down
}

public struct PriceAlert: Codable, Equatable, Hashable, Sendable {
	public let assetId: String
	public let price: Double?
	public let pricePercentChange: Double?
	public let priceDirection: PriceAlertDirection?

	public init(assetId: String, price: Double?, pricePercentChange: Double?, priceDirection: PriceAlertDirection?) {
		self.assetId = assetId
		self.price = price
		self.pricePercentChange = pricePercentChange
		self.priceDirection = priceDirection
	}
}

public struct PriceAlertData: Codable, Equatable, Hashable, Sendable {
	public let asset: Asset
	public let price: Price?
	public let priceAlert: PriceAlert

	public init(asset: Asset, price: Price?, priceAlert: PriceAlert) {
		self.asset = asset
		self.price = price
		self.priceAlert = priceAlert
	}
}
