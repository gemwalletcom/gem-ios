/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct BlockExplorerLink: Codable, Equatable, Hashable, Sendable {
	public let name: String
	public let link: String

	public init(name: String, link: String) {
		self.name = name
		self.link = link
	}
}
