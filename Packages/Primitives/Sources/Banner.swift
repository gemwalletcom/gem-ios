/*
 Generated by typeshare 1.9.2
 */

import Foundation

public enum BannerEvent: String, Codable, CaseIterable, Equatable {
	case stake
	case accountActivation
}

public enum BannerState: String, Codable, CaseIterable, Equatable {
	case active
	case cancelled
	case alwaysActive
}

public struct Banner: Codable, Equatable {
	public let wallet: Wallet?
	public let asset: Asset?
	public let event: BannerEvent
	public let state: BannerState

	public init(wallet: Wallet?, asset: Asset?, event: BannerEvent, state: BannerState) {
		self.wallet = wallet
		self.asset = asset
		self.event = event
		self.state = state
	}
}
