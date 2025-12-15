// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Dictionary where Key: Encodable, Value: Encodable {
    func mapTo<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: try JSONEncoder().encode(self))
    }
}
