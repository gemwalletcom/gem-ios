/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct TonResult<T: Codable>: Codable {
	public let result: T

	public init(result: T) {
		self.result = result
	}
}
