/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct TronChainParameter: Codable {
	public let key: String
	public let value: Int64?

	public init(key: String, value: Int64?) {
		self.key = key
		self.value = value
	}
}

public struct TronChainParameters: Codable {
	public let chainParameter: [TronChainParameter]

	public init(chainParameter: [TronChainParameter]) {
		self.chainParameter = chainParameter
	}
}

public enum TronChainParameterKey: String, Codable, Equatable {
	case getCreateNewAccountFeeInSystemContract
	case getCreateAccountFee
	case getEnergyFee
}
