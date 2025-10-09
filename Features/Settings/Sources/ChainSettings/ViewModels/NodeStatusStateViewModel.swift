// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Style
import Localization
import SwiftUI
import Formatters

struct NodeStatusStateViewModel: Sendable {
    let nodeStatus: NodeStatusState

    public func latestBlockText(title: String, formatter: ValueFormatter) -> String {
        let value = switch nodeStatus {
        case .result(let nodeStatus): formatter.string(nodeStatus.latestBlockNumber, decimals: 0)
        case .error, .none: "-"
        }
        return "\(title): \(value)"
    }

    public var latencyText: String? {
        switch nodeStatus {
        case .result(let nodeStatus):
            if nodeStatus.latestBlockNumber > 0 {
                return LatencyViewModel(latency: nodeStatus.latency).title
            }
            return Localized.Errors.error
        case .error:
            return Localized.Errors.error
        case .none:
            return ""
        }
    }

    public var color: Color {
        switch nodeStatus {
        case .error: Colors.red
        case .none: Colors.gray
        case .result(let nodeStatus):
            nodeStatus.latestBlockNumber.isZero ? Colors.red : LatencyViewModel(latency: nodeStatus.latency).color
        }
    }

    public var background: Color {
        switch nodeStatus {
        case .error: Colors.red.opacity(0.15)
        case .none: .clear
        case .result(let nodeStatus):
            nodeStatus.latestBlockNumber.isZero ? Colors.red.opacity(0.15) : LatencyViewModel(latency: nodeStatus.latency).background
        }
    }
}
