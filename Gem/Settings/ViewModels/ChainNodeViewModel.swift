// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components
import Style

struct ChainNodeViewModel {
    let chainNode: ChainNode
    let nodeMetrics: NodeMetrics?
    let valueFormatter: ValueFormatter

    init(chainNode: ChainNode, nodeMetrics: NodeMetrics?, valueFormatter: ValueFormatter) {
        self.chainNode = chainNode
        self.nodeMetrics = nodeMetrics
        self.valueFormatter = valueFormatter
    }

    var title: String {
        guard let host = chainNode.host else { return "" }
        return chainNode.isGemNode ? "Gem Wallet Node" : host
    }

    var titleExtra: String? {
        NodeMetricsFormatter(metrics: nodeMetrics)
            .latestBlockFormatted(
                latestBlockTitle: Localized.Nodes.ImportNode.latestBlock,
                valueFormatter: valueFormatter
            )
    }

    var subtitle: String? {
        NodeMetricsFormatter(metrics: nodeMetrics)
            .latencyFormatted
    }

    var placeholders: [ListItemViewPlaceholderType] {
        nodeMetrics?.error != nil ? [] : [.subtitle]
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

struct NodeMetricsFormatter {
    let metrics: NodeMetrics?

    func latestBlockFormatted(latestBlockTitle: String, valueFormatter: ValueFormatter) -> String? {
        if let error = metrics?.error {
            return Self.isNotImplemented(error: error) ? nil : "\(latestBlockTitle): -"
        }

        if let blockNumber = metrics?.blockNumber {
            let formattedBlockNumber = valueFormatter.string(blockNumber, decimals: 0)
            return "\(latestBlockTitle): \(formattedBlockNumber)"
        }

        return "\(latestBlockTitle): -"
    }

    var latencyFormatted: String? {
        if let error = metrics?.error {
            return Self.isNotImplemented(error: error) ? nil : "\(Localized.Errors.error) \(Emoji.redCircle)"
        }

        if let latency = metrics?.latency {
            return "\(Localized.Common.latencyInMs(latency.value)) \(latency.colorEmoji)"
        }

        return nil
    }

    private static func isNotImplemented(error: Error) -> Bool {
        return error.localizedDescription == "Not Implemented"
    }
}
