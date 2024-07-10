// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components

struct ChainNodeViewModel {
    let chainNode: ChainNode

    private let blockNumber: BigInt?
    private let latency: LatencyMeasureService.Latency?
    private let blockNumberError: Error?

    private static let valueFormatter = ValueFormatter.full_US

    init(chainNode: ChainNode, blockNumber: BigInt?, latency: LatencyMeasureService.Latency?, blockNumberError: Error?) {
        self.chainNode = chainNode
        self.blockNumber = blockNumber
        self.latency = latency
        self.blockNumberError = blockNumberError
    }

    var title: String {
        guard let host = chainNode.host else { return "" }
        return chainNode.isGemNode ? "Gem Wallet Node" : host
    }

    var titleExtra: String? {
        let title = Localized.Nodes.ImportNode.latestBlock
        let emptyTitle = "\(title): -"
        if let blockNumberError {
            return Self.isNotImplemented(error: blockNumberError) ? nil  : emptyTitle
        }

        if let blockNumber {
            let formattedBlockNumber = ChainNodeViewModel.valueFormatter.string(blockNumber, decimals: 0)
            return "\(title): \(formattedBlockNumber)"
        }

        return emptyTitle
    }

    var subtitle: String? {
        if let blockNumberError {
            return Self.isNotImplemented(error: blockNumberError) ? nil  : "\(Localized.Errors.error) 🔴"
        }
        if let latency {
            return "\(Localized.Common.latencyInMs(latency.value)) \((latency.colorEmoji))"
        }
        return nil
    }

    var sortValue: (isGemNode: Bool, latency: Int?) {
        let isGemNode = chainNode.isGemNode
        let latencyValue = latency?.value
        return (isGemNode, latencyValue)
    }

    var placeholders: [ListItemViewPlaceholderType] {
        blockNumberError != nil ? [] : [.subtitle]
    }
}

// MARK: - Private

extension ChainNodeViewModel {
    private static func isNotImplemented(error: Error) -> Bool {
        return error.localizedDescription == "Not Implemented"
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
