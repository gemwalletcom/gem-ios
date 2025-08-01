/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct AssetScore: Codable, Equatable, Sendable {
	public let rank: Int32

	public init(rank: Int32) {
		self.rank = rank
	}
}

public enum AssetRank: String, Codable, CaseIterable, Equatable, Sendable {
	case high
	case medium
	case low
	case trivial
	case inactive
	case abandoned
	case suspended
	case migrated
	case deprecated
	case spam
	case fraudulent
	case unknown
}

public enum AssetScoreType: String, Codable, Equatable, Sendable {
	case verified
	case unverified
	case suspicious
}
