// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Style
import Localization
import SwiftUI

struct NodeStatusViewModel {
    let nodeStatus: NodeStatus

    func latestBlockText(title: String, formatter: ValueFormatter) -> String {
        let value = switch nodeStatus {
        case .result(let blockNumber, _): formatter.string(blockNumber, decimals: 0)
        case .error, .none: "-"
        }
        return "\(title): \(value)"
    }

    var latencyText: String? {
        switch nodeStatus {
        case .result(let block, let latency):
            if block > 0 {
                return LatencyViewModel(latency: latency).title
            }
            return Localized.Errors.error
        case .error:
            return Localized.Errors.error
        case .none:
            return ""
        }
    }

    var color: Color {
        switch nodeStatus {
        case .error: Colors.red
        case .none: Colors.gray
        case .result(_, let latency):
            LatencyViewModel(latency: latency).color
        }
    }

    var background: Color {
        switch nodeStatus {
        case .error: Colors.red.opacity(0.15)
        case .none: .clear
        case .result(_, let latency):
            LatencyViewModel(latency: latency).background
        }
    }
}
