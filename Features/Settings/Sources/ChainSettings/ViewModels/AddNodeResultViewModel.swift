// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import Localization
import Formatters

public struct AddNodeResultViewModel: Sendable {
    static let valueFormatter = ValueFormatter.full_US

    private let addNodeResult: AddNodeResult

    public init(addNodeResult: AddNodeResult) {
        self.addNodeResult = addNodeResult
    }
    
    public var url: URL { addNodeResult.url }

    public var chainIdTitle: String { Localized.Nodes.ImportNode.chainId }
    public var chainIdValue: String { addNodeResult.chainID }

    public var isInSync: Bool { addNodeResult.isInSync }
    public var inSyncTitle: String { Localized.Nodes.ImportNode.inSync }
    public var inSyncValue: String? { isInSync ? Emoji.checkmark : Emoji.reject }

    public var latestBlockTitle: String { Localized.Nodes.ImportNode.latestBlock }
    public var latestBlockValue: String? {
        Self.valueFormatter.string(addNodeResult.blockNumber, decimals: 0)
    }

    public var latencyTitle: String { Localized.Nodes.ImportNode.latency }
    public var latecyValue: String? {
        LatencyViewModel(latency: addNodeResult.latency).title
    }
}
