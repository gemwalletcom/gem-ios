/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct FiatProvider: Codable, Equatable, Sendable {
	public let name: String
	public let imageUrl: String

	public init(name: String, imageUrl: String) {
		self.name = name
		self.imageUrl = imageUrl
	}
}
