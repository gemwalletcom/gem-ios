/*
 Generated by typeshare 1.11.0
 */

import Foundation

public enum TransactionType: String, Codable, CaseIterable, Equatable, Sendable {
	case transfer
	case swap
	case tokenApproval
	case stakeDelegate
	case stakeUndelegate
	case stakeRewards
	case stakeRedelegate
	case stakeWithdraw
	case assetActivation
}
