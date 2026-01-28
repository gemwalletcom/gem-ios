// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import Localization
import Formatters

struct AddNodeResultViewModel: Sendable {
    static let valueFormatter = ValueFormatter.full_US

    private let addNodeResult: AddNodeResult

    init(addNodeResult: AddNodeResult) {
        self.addNodeResult = addNodeResult
    }
    
    var url: URL { addNodeResult.url }

    var chainIdTitle: String { Localized.Nodes.ImportNode.chainId }
    var chainIdValue: String { addNodeResult.chainID }

    var isInSync: Bool { addNodeResult.isInSync }
    var inSyncTitle: String { Localized.Nodes.ImportNode.inSync }
    var inSyncValue: String? { isInSync ? Emoji.checkmark : Emoji.reject }

    var latestBlockTitle: String { Localized.Nodes.ImportNode.latestBlock }
    var latestBlockValue: String? {
        Self.valueFormatter.string(addNodeResult.blockNumber, decimals: 0)
    }

    var latencyTitle: String { Localized.Nodes.ImportNode.latency }
    var latecyValue: String? {
        LatencyViewModel(latency: addNodeResult.latency).title
    }
}
