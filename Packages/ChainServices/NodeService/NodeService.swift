// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import ChainService
import class Gemstone.Config
import GemstonePrimitives

public final class NodeService: Sendable {
    public let nodeStore: NodeStore

    public init(
        nodeStore: NodeStore
    ) {
        self.nodeStore = nodeStore
    }

    public func getNodeSelected(chain: Chain) -> ChainNode {
        guard
            let url = try? nodeStore.selectedNodeUrl(chain: chain),
            let node = try? nodes(for: chain).first(where: { $0.node.url == url })
        else {
            return chain.defaultChainNode
        }
        return node
    }

    public func setNodeSelected(chain: Chain, node: Primitives.Node) throws {
        try nodeStore.setNodeSelected(chain: chain, url: node.url)
    }

    public func delete(chain: Chain, node: Primitives.Node) throws {
        try nodeStore.deleteNode(chain: chain, url: node.url)
        try nodeStore.deleteNodeSelected(chain: chain)
    }

    public func nodes(for chain: Chain) throws -> [ChainNode] {
        let nodes = try nodeStore.nodes(chain: chain)
        return ([
            chain.defaultChainNode,
            chain.asiaChainNode,
            chain.europeChainNode,
        ] + nodes).unique()
    }

    public func update(chain: Chain, force: Bool = false) throws {
        // TODO: - implement later
        /*
        guard !requestedChains.contains(chain) else { return }
        let nodes = try nodeStore.nodeRecords(chain: chain)
        requestedChains.insert(chain)
         */
    }
}

// MARK: - NodeURLFetchable

extension NodeService: NodeURLFetchable {
    public func node(for chain: Chain) -> URL {
        guard let url = try? nodeStore.selectedNodeUrl(chain: chain)?.asURL else {
            return chain.defaultBaseUrl
        }
        return url
    }
}

// MARK: - Static

extension NodeService {
    public static func defaultNodes(chain: Chain) -> [ChainNode] {
        let nodes = Config.shared.getNodes()[chain.rawValue] ?? []
        return nodes.map({ ChainNode(chain: chain.rawValue, node: $0.node) })
    }

    public static func isValid(netoworkId: String, for chain: Chain) -> Bool {
        ChainConfig.config(chain: chain).networkId == netoworkId
    }
}
