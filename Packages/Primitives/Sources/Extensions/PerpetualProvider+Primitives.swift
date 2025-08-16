// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PerpetualProvider {
    public init(id: String) throws {
        if let provider = PerpetualProvider(rawValue: id) {
            self = provider
        } else {
            throw AnyError("invalid perpetual provider: \(id)")
        }
    }
}