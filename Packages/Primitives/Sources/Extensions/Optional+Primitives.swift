// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Optional {
    func unwrapOrThrow() throws -> Wrapped {
        guard let value = self else {
            throw AnyError("Value is nil")
        }
        return value
    }
    
    func or(_ defaultValue: Wrapped) -> Wrapped {
        self ?? defaultValue
    }
}
