/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct StakeValidator: Codable, Equatable, Hashable, Sendable {
	public let id: String
	public let name: String

	public init(id: String, name: String) {
		self.id = id
		self.name = name
	}
}
