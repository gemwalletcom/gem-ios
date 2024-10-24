// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum InfoSheetType: Identifiable, Sendable {
    case networkFees
    case transactionStatus

    public var id: Self { self }
}
