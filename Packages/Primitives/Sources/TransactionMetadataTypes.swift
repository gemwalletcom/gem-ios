/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct TransactionNFTTransferMetadata: Codable, Sendable {
	public let assetId: String

	public init(assetId: String) {
		self.assetId = assetId
	}
}

public struct TransactionSwapMetadata: Codable, Sendable {
	public let fromAsset: AssetId
	public let fromValue: String
	public let toAsset: AssetId
	public let toValue: String
	public let provider: String?

	public init(fromAsset: AssetId, fromValue: String, toAsset: AssetId, toValue: String, provider: String?) {
		self.fromAsset = fromAsset
		self.fromValue = fromValue
		self.toAsset = toAsset
		self.toValue = toValue
		self.provider = provider
	}
}
