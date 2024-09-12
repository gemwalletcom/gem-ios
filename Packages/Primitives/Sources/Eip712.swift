/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct EIP712Domain: Codable, Equatable {
	public let name: String
	public let version: String
	public let chainId: UInt32
	public let verifyingContract: String

	public init(name: String, version: String, chainId: UInt32, verifyingContract: String) {
		self.name = name
		self.version = version
		self.chainId = chainId
		self.verifyingContract = verifyingContract
	}
}

public struct EIP712Type: Codable, Equatable {
	public let name: String
	public let type: String

	public init(name: String, type: String) {
		self.name = name
		self.type = type
	}
}
