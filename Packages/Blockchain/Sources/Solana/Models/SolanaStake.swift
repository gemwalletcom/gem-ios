/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct SolanaEpoch: Codable, Sendable {
	public let epoch: Int32
	public let slotIndex: Int32
	public let slotsInEpoch: Int32

	public init(epoch: Int32, slotIndex: Int32, slotsInEpoch: Int32) {
		self.epoch = epoch
		self.slotIndex = slotIndex
		self.slotsInEpoch = slotsInEpoch
	}
}

public struct SolanaValidator: Codable, Sendable {
	public let votePubkey: String
	public let commission: Int32
	public let epochVoteAccount: Bool

	public init(votePubkey: String, commission: Int32, epochVoteAccount: Bool) {
		self.votePubkey = votePubkey
		self.commission = commission
		self.epochVoteAccount = epochVoteAccount
	}
}

public struct SolanaValidators: Codable, Sendable {
	public let current: [SolanaValidator]

	public init(current: [SolanaValidator]) {
		self.current = current
	}
}
