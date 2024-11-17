// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum InfoSheetType: Identifiable, Sendable {
    case networkFee(Chain)
    case transactionState(imageURL: URL?, state: TransactionState)
    case watchWallet

    public var id: String {
        switch self {
        case .networkFee: "networkFees"
        case .transactionState(_, let state): state.id
        case .watchWallet: "watchWallet"
        }
    }
}
