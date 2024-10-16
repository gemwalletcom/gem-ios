// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components
import Style
import Localization

struct ChainNodeViewModel {
    let chainNode: ChainNode
    let nodeStatus: NodeStatus
    let formatter: ValueFormatter

    init(chainNode: ChainNode, nodeStatus: NodeStatus, formatter: ValueFormatter) {
        self.chainNode = chainNode
        self.nodeStatus = nodeStatus
        self.formatter = formatter
    }

    var title: String {
        guard let host = chainNode.host else { return "" }
        return chainNode.isGemNode ? Localized.Nodes.gemWalletNode : host
    }

    var titleExtra: String? {
        NodeStatusViewModel(nodeStatus: nodeStatus)
            .latestBlockText(
                title: Localized.Nodes.ImportNode.latestBlock,
                formatter: formatter
            )
    }

    var subtitle: String? {
        NodeStatusViewModel(nodeStatus: nodeStatus).latencyText
    }

    var placeholders: [ListItemViewPlaceholderType] {
        switch nodeStatus {
        case .result, .error: []
        case .none: [.subtitle]
        }
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

