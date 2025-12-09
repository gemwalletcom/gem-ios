// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Encodable {
    func toDictionary() throws -> [String: String] {
        let data = try JSONEncoder().encode(self)
        return try JSONDecoder().decode([String: String].self, from: data)
    }
}
