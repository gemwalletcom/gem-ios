// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style

struct LatencyViewModel {
    
    let latency: Latency

    var title: String {
        "\(Localized.Common.latencyInMs(value)) \(colorEmoji)"
    }

    var colorEmoji: String {
        switch latency.type {
        case .fast: return Emoji.greenCircle
        case .normal: return Emoji.orangeCircle
        case .slow: return Emoji.redCircle
        }
    }

    var value: Int {
        return Int(latency.value)
    }
}
