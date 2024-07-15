// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components
import Style

struct ChainNodeViewModel {
    let chainNode: ChainNode
    let nodeStatusInfo: NodeStatusInfo?
    let valueFormatter: ValueFormatter

    init(chainNode: ChainNode, nodeStatusInfo: NodeStatusInfo?, valueFormatter: ValueFormatter) {
        self.chainNode = chainNode
        self.nodeStatusInfo = nodeStatusInfo
        self.valueFormatter = valueFormatter
    }

    var title: String {
        guard let host = chainNode.host else { return "" }
        return chainNode.isGemNode ? Localized.Nodes.gemWalletNode : host
    }

    var titleExtra: String? {
        NodeStatusViewModel(statusInfo: nodeStatusInfo)
            .latestBlockText(
                latestBlockTitle: Localized.Nodes.ImportNode.latestBlock,
                valueFormatter: valueFormatter
            )
    }

    var subtitle: String? {
        NodeStatusViewModel(statusInfo: nodeStatusInfo)
            .latencyText
    }

    var placeholders: [ListItemViewPlaceholderType] {
        guard let nodeStatusInfo = nodeStatusInfo else {
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

