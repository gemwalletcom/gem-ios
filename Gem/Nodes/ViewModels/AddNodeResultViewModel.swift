// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AddNodeResultViewModel {
    static var valueFormatter = ValueFormatter.full_US

    private let addNodeResult: AddNodeResult

    init(addNodeResult: AddNodeResult) {
        self.addNodeResult = addNodeResult
    }

    var chainIdTitle: String { Localized.Nodes.ImportNode.chainId }
    var chainIdValue: String? { addNodeResult.chainID }

    var isInSync: Bool { addNodeResult.isInSync }
    var inSyncTitle: String { Localized.Nodes.ImportNode.inSync }
    var inSyncValue: String? { isInSync ? "✅" : "❌" }

    var latestBlockTitle: String { Localized.Nodes.ImportNode.latestBlock }
    var latestBlockValue: String? {
        Self.valueFormatter.string(addNodeResult.blockNumber, decimals: 0)
    }

    var latencyTitle: String { Localized.Nodes.ImportNode.latency }
    var latecyValue: String? {
        let latency = addNodeResult.latency
        return "\(Localized.Common.latencyInMs(latency.value)) \(latency.colorEmoji)"
    }
}
