// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum JSON<Value>: Encodable where Value: Encodable {
    case bool(Bool)
    case integer(Int)
    case string(String)
    case value(Value)
    case dictionary([String: JSON])
    case array([JSON])
    case null
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .integer(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .value(let value):
            try container.encode(value)
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
