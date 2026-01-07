// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionWalletConnectMetadata: Codable, Sendable {
    public let outputAction: TransferDataOutputAction

    public init(outputAction: TransferDataOutputAction) {
        self.outputAction = outputAction
    }
}
