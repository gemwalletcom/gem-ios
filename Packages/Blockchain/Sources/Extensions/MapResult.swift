// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public extension Response {

    func mapResult<T: Codable>(_ type: T.Type, decoder: JSONDecoder = Self.standardDecoder) throws -> T {
        return try decoder.decode(JSONRPCResponse<T>.self, from: body).result
    }

    func mapResultOrError<T: Codable>(as type: T.Type, decoder: JSONDecoder = Self.standardDecoder) throws -> T {
        return try self.mapOrError(as: JSONRPCResponse<T>.self, asError: JSONRPCError.self, decoder).result
    }
}
