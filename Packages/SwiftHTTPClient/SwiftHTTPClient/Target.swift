// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol TargetType: Sendable {
    var baseUrl: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var data: RequestData { get }
    var contentType: String { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

public enum ContentType: String {
    case json = "application/json"
    case plainText = "text/plain"
    case URLEncoded = "application/x-www-form-urlencoded"
    case XBinary = "application/x-binary"
}

public extension TargetType {
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
}

public extension TargetType {
    var contentType: String {
        return ContentType.json.rawValue
    }
}
