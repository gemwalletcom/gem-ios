// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components
import Style

struct ChainNodeViewModel {
    let chainNode: ChainNode
    let nodeStatus: NodeStatus?
    let valueFormatter: ValueFormatter

    init(chainNode: ChainNode, nodeStatus: NodeStatus?, valueFormatter: ValueFormatter) {
        self.chainNode = chainNode
        self.nodeStatus = nodeStatus
        self.valueFormatter = valueFormatter
    }

    var title: String {
        guard let host = chainNode.host else { return "" }
        return chainNode.isGemNode ? Localized.Nodes.gemWalletNode : host
    }

    var titleExtra: String? {
        NodeStatusViewModel(nodeStatus: nodeStatus)
            .latestBlockText(
                latestBlockTitle: Localized.Nodes.ImportNode.latestBlock,
                valueFormatter: valueFormatter
            )
    }

    var subtitle: String? {
        NodeStatusViewModel(nodeStatus: nodeStatus)
            .latencyText
    }

    var placeholders: [ListItemViewPlaceholderType] {
        guard let nodeStatus = nodeStatus else {
            return [.subtitle]
        }
        return []
    }
}

// MARK: - Identifiable

extension ChainNodeViewModel: Identifiable {
    var id: String { chainNode.id }
}

// MARK: - Models extensions

extension ChainNode {
    var host: String? {
        URL(string: node.url)?.host
    }

    var isGemNode: Bool {
        host?.contains("gemnodes.com") ?? false
    }
}

