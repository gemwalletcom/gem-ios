/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct BitcoinBlock: Codable, Sendable {
	public let previousBlockHash: String?

	public init(previousBlockHash: String?) {
		self.previousBlockHash = previousBlockHash
	}
}
