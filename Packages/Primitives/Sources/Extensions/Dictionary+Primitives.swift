// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension [String: String] {
    func mapTo<T: Decodable>(_ type: T.Type) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode(type, from: data)
    }
}
