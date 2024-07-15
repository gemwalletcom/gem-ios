// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

enum NodeStatusInfo {
    case result(blockNumber: BigInt?, latency: LatencyMeasureService.Latency)
    case error(error: Error?)

    var error: Error? {
        switch self {
        case let .error(error):
            return error
        default:
            return nil
        }
    }

    var result: (blockNumber: BigInt?, latency: LatencyMeasureService.Latency)? {
        switch self {
        case let .result(block, latency):
            return (block, latency)
        default:
            return nil
        }
    }
}
