// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension TransactionResourceTypeMetadata {
    public func toGeneric() -> [String: String]? {
        try? JSONDecoder().decode([String: String].self, from: try JSONEncoder().encode(self))
    }
}
