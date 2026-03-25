// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension FiatTransaction: Identifiable {}

extension FiatTransactionInfo: Identifiable {
    public var id: String { transaction.id }
}
