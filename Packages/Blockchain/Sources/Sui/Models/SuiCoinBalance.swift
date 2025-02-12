/*
 Generated by typeshare 1.12.0
 */

import Foundation

public struct SuiCoin: Codable, Sendable {
	public let coinType: String
	public let coinObjectId: String
	public let balance: String
	public let version: String
	public let digest: String

	public init(coinType: String, coinObjectId: String, balance: String, version: String, digest: String) {
		self.coinType = coinType
		self.coinObjectId = coinObjectId
		self.balance = balance
		self.version = version
		self.digest = digest
	}
}

public struct SuiCoinBalance: Codable, Sendable {
	public let coinType: String
	public let totalBalance: String

	public init(coinType: String, totalBalance: String) {
		self.coinType = coinType
		self.totalBalance = totalBalance
	}
}

public struct SuiData<T: Codable & Sendable>: Codable, Sendable {
	public let data: T

	public init(data: T) {
		self.data = data
	}
}

public struct SuiGasUsed: Codable, Sendable {
	public let computationCost: String
	public let storageCost: String
	public let storageRebate: String
	public let nonRefundableStorageFee: String

	public init(computationCost: String, storageCost: String, storageRebate: String, nonRefundableStorageFee: String) {
		self.computationCost = computationCost
		self.storageCost = storageCost
		self.storageRebate = storageRebate
		self.nonRefundableStorageFee = nonRefundableStorageFee
	}
}

public struct SuiStatus: Codable, Sendable {
	public let status: String

	public init(status: String) {
		self.status = status
	}
}

public struct SuiObjectReference: Codable, Sendable {
	public let objectId: String

	public init(objectId: String) {
		self.objectId = objectId
	}
}

public struct SuiObjectChange: Codable, Sendable {
	public let reference: SuiObjectReference

	public init(reference: SuiObjectReference) {
		self.reference = reference
	}
}

public struct SuiEffects: Codable, Sendable {
	public let gasUsed: SuiGasUsed
	public let status: SuiStatus
	public let created: [SuiObjectChange]?

	public init(gasUsed: SuiGasUsed, status: SuiStatus, created: [SuiObjectChange]?) {
		self.gasUsed = gasUsed
		self.status = status
		self.created = created
	}
}

public struct SuiTransaction: Codable, Sendable {
	public let effects: SuiEffects

	public init(effects: SuiEffects) {
		self.effects = effects
	}
}
