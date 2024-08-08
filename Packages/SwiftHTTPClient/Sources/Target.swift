import Foundation

public protocol TargetType {
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
