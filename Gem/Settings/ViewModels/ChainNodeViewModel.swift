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

    var titleTag: String? {
        NodeStatusViewModel(nodeStatus: nodeStatus).latencyText
    }

    var titleTagType: TitleTagType {
        switch nodeStatus {
        case .result, .error: .none
        case .none: .progressView(scale: 1.24)
        }
    }

    var titleTagStyle: TextStyle {
        let model = NodeStatusViewModel(nodeStatus: nodeStatus)
        return TextStyle(
            font: .footnote.weight(.medium),
            color: model.color,
            background: model.background
        )
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

