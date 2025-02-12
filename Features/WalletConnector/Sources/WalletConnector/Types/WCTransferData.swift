// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct WCTransferData: Identifiable, Sendable {
    public let tranferData: TransferData
    public let wallet: Wallet

    public init(tranferData: TransferData, wallet: Wallet) {
        self.tranferData = tranferData
        self.wallet = wallet
    }

    public var id: String { wallet.id }
}
