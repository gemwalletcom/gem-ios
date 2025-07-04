/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct AptosGasFee: Codable, Sendable {
	public let deprioritized_gas_estimate: UInt64
	public let gas_estimate: UInt64
	public let prioritized_gas_estimate: UInt64

	public init(deprioritized_gas_estimate: UInt64, gas_estimate: UInt64, prioritized_gas_estimate: UInt64) {
		self.deprioritized_gas_estimate = deprioritized_gas_estimate
		self.gas_estimate = gas_estimate
		self.prioritized_gas_estimate = prioritized_gas_estimate
	}
}
