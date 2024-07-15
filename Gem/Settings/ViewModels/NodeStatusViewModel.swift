// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Style

struct NodeStatusViewModel {
    let nodeStatus: NodeStatus?

    func latestBlockText(latestBlockTitle: String, valueFormatter: ValueFormatter) -> String? {
        guard let nodeStatus = nodeStatus else { return "\(latestBlockTitle): -" }
        switch nodeStatus {
        case let .result(blockNumber, _):
            let formattedBlockNumber = valueFormatter.string(blockNumber, decimals: 0)
            return "\(latestBlockTitle): \(formattedBlockNumber)"
        case .error(let error):
            return "\(latestBlockTitle): -"
        }    }

    var latencyText: String? {
        guard let nodeStatus = nodeStatus else { return nil }
        switch nodeStatus {
        case .result(let blockNumber, let latency):
            return "\(Localized.Common.latencyInMs(latency.value)) \(latency.colorEmoji)"
        case .error(let error):
            return "\(Localized.Errors.error) \(Emoji.redCircle)"
        }
    }
}
