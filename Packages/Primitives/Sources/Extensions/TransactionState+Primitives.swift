// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension TransactionState: Identifiable {
    public var id: String { rawValue }
    
    public var isPending: Bool {
        self == .pending
    }
}
