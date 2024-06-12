/*
 Generated by typeshare 1.9.2
 */

import Foundation

public enum NodeStatus: String, Codable, CaseIterable, Equatable {
	case active
	case inactive
}

public struct Node: Codable {
	public let url: String
	public let status: NodeStatus
	public let priority: Int32

	public init(url: String, status: NodeStatus, priority: Int32) {
		self.url = url
		self.status = status
		self.priority = priority
	}
}

public struct ChainNode: Codable {
	public let chain: String
	public let node: Node

	public init(chain: String, node: Node) {
		self.chain = chain
		self.node = node
	}
}

public struct ChainNodes: Codable {
	public let chain: String
	public let nodes: [Node]

	public init(chain: String, nodes: [Node]) {
		self.chain = chain
		self.nodes = nodes
	}
}

public struct NodesResponse: Codable {
	public let version: Int32
	public let nodes: [ChainNodes]

	public init(version: Int32, nodes: [ChainNodes]) {
		self.version = version
		self.nodes = nodes
	}
}

public enum NodePriority: String, Codable, CaseIterable, Equatable {
	case high
	case medium
	case low
	case inactive
}
