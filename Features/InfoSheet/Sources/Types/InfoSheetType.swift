// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

public enum InfoSheetType: Identifiable, Sendable {
    case networkFee(Chain)
    case transactionState(imageURL: URL?, placeholder: Image?, state: TransactionState)
    case watchWallet
    case stakeLockTime(Image?)

    public var id: String {
        switch self {
        case .networkFee: "networkFees"
        case .transactionState(_, _, let state): state.id
        case .watchWallet: "watchWallet"
        case .stakeLockTime: "stakeLockTime"
        }
    }
}
