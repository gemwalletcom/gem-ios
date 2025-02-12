/*
 Generated by typeshare 1.12.0
 */

import Foundation

public struct SolanaTransactionError: Codable, Sendable {
	public init() {}
}

public struct SolanaTransactionMeta: Codable, Sendable {
	public let err: SolanaTransactionError?

	public init(err: SolanaTransactionError?) {
		self.err = err
	}
}

public struct SolanaTransaction: Codable, Sendable {
	public let meta: SolanaTransactionMeta
	public let slot: Int32

	public init(meta: SolanaTransactionMeta, slot: Int32) {
		self.meta = meta
		self.slot = slot
	}
}
