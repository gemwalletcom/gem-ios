// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension TransactionState: Identifiable {
    public var id: String { rawValue }
    
    public var isPending: Bool {
        self == .pending
    }
}

extension TransactionState {
    public init(id: String) throws {
        if let state = TransactionState(rawValue: id) {
            self = state
        } else {
            throw AnyError("invalid state: \(id)")
        }
    }
}
