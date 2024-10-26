// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum URLDecoderError: LocalizedError {
    case unsupportedScheme
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedScheme: "Expected URL to start with https"
        }
    }
}

public struct URLDecoder {
    public init() {}
    
    public func decode(_ string: String) throws -> URL? {
        if !string.hasPrefix("http") {
            return URL(string: "https://" + string)
        } else if string.hasPrefix("http://") {
            throw URLDecoderError.unsupportedScheme
        }
        return URL(string: string)
    }
}
