// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct TransactionHeaderItemModel {
    public let headerType: TransactionHeaderType
    public let showClearHeader: Bool
    
    public init(
        headerType: TransactionHeaderType,
        showClearHeader: Bool
    ) {
        self.headerType = headerType
        self.showClearHeader = showClearHeader
    }
}
