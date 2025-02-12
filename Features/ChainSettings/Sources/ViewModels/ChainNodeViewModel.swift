// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Style
import Localization

public struct ChainNodeViewModel: Sendable {
    public let chainNode: ChainNode
    private let nodeStatus: NodeStatus
    private let formatter: ValueFormatter

    public init(
        chainNode: ChainNode,
        nodeStatus: NodeStatus,
        formatter: ValueFormatter
    ) {
        self.chainNode = chainNode
        self.nodeStatus = nodeStatus
        self.formatter = formatter
    }

    public var title: String {
        guard let host = chainNode.host else { return "" }
        return chainNode.isGemNode ? Localized.Nodes.gemWalletNode : host
    }

    public var titleExtra: String? {
        nodeStatusModel
            .latestBlockText(
                title: Localized.Nodes.ImportNode.latestBlock,
                formatter: formatter
            )
    }

    public var titleTag: String? {
        nodeStatusModel.latencyText
    }

    public var titleTagType: TitleTagType {
        switch nodeStatus {
        case .result, .error: .none
        case .none: .progressView(scale: 1.24)
        }
    }

    public var titleTagStyle: TextStyle {
        return TextStyle(
            font: .footnote.weight(.medium),
            color: nodeStatusModel.color,
            background: nodeStatusModel.background
        )
    }

    private var nodeStatusModel: NodeStatusViewModel {
        NodeStatusViewModel(nodeStatus: nodeStatus)
    }
}

// MARK: - Identifiable

extension ChainNodeViewModel: Identifiable {
    public var id: String { chainNode.id }
}

// MARK: - Models extensions

extension ChainNode {
    public var host: String? {
        URL(string: node.url)?.host
    }

    public var isGemNode: Bool {
        host?.contains("gemnodes.com") ?? false
    }
}

