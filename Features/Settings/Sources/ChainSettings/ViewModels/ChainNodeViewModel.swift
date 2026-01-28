// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Style
import Localization
import Formatters

struct ChainNodeViewModel: Sendable {
    let chainNode: ChainNode

    private let statusState: NodeStatusState
    private let formatter: ValueFormatter

    init(
        chainNode: ChainNode,
        statusState: NodeStatusState,
        formatter: ValueFormatter
    ) {
        self.chainNode = chainNode
        self.statusState = statusState
        self.formatter = formatter
    }

    var title: String {
        guard let host = chainNode.host else { return "" }

        let flag: String? = {
            switch host {
            case Constants.nodesAsiaURL.cleanHost(): "🇯🇵"
            case Constants.nodesEuropeURL.cleanHost(): "🇪🇺"
            case Constants.nodesURL.cleanHost(): "🇺🇸"
            default: nil
            }
        }()

        if let flag {
            return Localized.Nodes.gemWalletNode + " " + flag
        }
        return host
    }

    var titleExtra: String? {
        nodeStatusModel
            .latestBlockText(
                title: Localized.Nodes.ImportNode.latestBlock,
                formatter: formatter
            )
    }

    var titleTag: String? {
        nodeStatusModel.latencyText
    }

    var titleTagType: TitleTagType {
        switch statusState {
        case .result, .error: .none
        case .none: .progressView(scale: 1.24)
        }
    }

    var titleTagStyle: TextStyle {
        return TextStyle(
            font: .footnote.weight(.medium),
            color: nodeStatusModel.color,
            background: nodeStatusModel.background
        )
    }

    private var nodeStatusModel: NodeStatusStateViewModel {
        NodeStatusStateViewModel(nodeStatus: statusState)
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

