// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Style

struct NodeStatusViewModel {
    let nodeStatus: NodeStatus

    func latestBlockText(title: String, formatter: ValueFormatter) -> String {
        let value = switch nodeStatus {
        case .result(let blockNumber, _): formatter.string(blockNumber, decimals: 0)
        case .error, .none: "-"
        }
        return "\(title): \(value)"
    }
    
    private var errorText: String {
        "\(Localized.Errors.error) \(Emoji.redCircle)"
    }

    var latencyText: String? {
        switch nodeStatus {
        case .result(let block, let latency):
            if block > 0 {
                return "\(Localized.Common.latencyInMs(latency.value)) \(latency.colorEmoji)"
            }
            return errorText
        case .error:
            return errorText
        case .none:
            return .none
        }
    }
}
