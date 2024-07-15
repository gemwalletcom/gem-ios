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
        NodeStatusFormatter(statusInfo: nodeStatusInfo)
            .latestBlockText(
                latestBlockTitle: Localized.Nodes.ImportNode.latestBlock,
                valueFormatter: valueFormatter
            )
    }

    var subtitle: String? {
        NodeStatusFormatter(statusInfo: nodeStatusInfo)
            .latencyText
    }

    var placeholders: [ListItemViewPlaceholderType] {
        nodeStatusInfo?.error != nil ? [] : [.subtitle]
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

// MARK: - Formatter

struct NodeStatusFormatter {
    let statusInfo: NodeStatusInfo?

    func latestBlockText(latestBlockTitle: String, valueFormatter: ValueFormatter) -> String? {
        if let error = statusInfo?.error {
            return Self.isNotImplemented(error: error) ? nil : "\(latestBlockTitle): -"
        }

        if let blockNumber = statusInfo?.result?.blockNumber {
            let formattedBlockNumber = valueFormatter.string(blockNumber, decimals: 0)
            return "\(latestBlockTitle): \(formattedBlockNumber)"
        }

        return "\(latestBlockTitle): -"
    }

    var latencyText: String? {
        if let error = statusInfo?.error {
            return Self.isNotImplemented(error: error) ? nil : "\(Localized.Errors.error) \(Emoji.redCircle)"
        }

        if let latency = statusInfo?.result?.latency {
            return "\(Localized.Common.latencyInMs(latency.value)) \(latency.colorEmoji)"
        }

        return nil
    }

    private static func isNotImplemented(error: Error) -> Bool {
        return error.localizedDescription == "Not Implemented"
    }
}
