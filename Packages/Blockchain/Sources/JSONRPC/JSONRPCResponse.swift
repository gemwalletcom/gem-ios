// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct JSONRPCResponse<T: Codable>: Codable {
    let jsonrpc: String
    let result: T
    let id: JSONRPCID
}

struct JSONRPCID: Codable {
    let id: String
    
    public init(id: String) {
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            id = String(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            id = stringValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ID format")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}

struct JSONRPCError: Codable {
    let error: JSONRPCErrorResult
}

struct JSONRPCErrorResult: Codable {
    let message: String
}

extension JSONRPCError: LocalizedError {
    public var errorDescription: String? {
        return error.message
    }
}
