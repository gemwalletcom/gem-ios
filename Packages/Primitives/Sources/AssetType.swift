/*
 Generated by typeshare 1.11.0
 */

import Foundation

public enum AssetSubtype: String, Codable, CaseIterable, Equatable, Sendable {
	case native = "NATIVE"
	case token = "TOKEN"
}

public enum AssetType: String, Codable, CaseIterable, Equatable, Sendable {
	case native = "NATIVE"
	case erc20 = "ERC20"
	case bep20 = "BEP20"
	case spl = "SPL"
	case trc20 = "TRC20"
	case token = "TOKEN"
	case ibc = "IBC"
	case jetton = "JETTON"
	case synth = "SYNTH"
	case asa = "ASA"
}
