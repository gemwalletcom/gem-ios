import Foundation
import Combine

public protocol ProviderType: Sendable {
    associatedtype Target: TargetType
}

public struct Provider<T: TargetType>: ProviderType {
    public typealias Target = T

    public let session: URLSession
    public let options: ProviderOptions
    
    public init(
        session: URLSession = .shared,
        options: ProviderOptions = ProviderOptions.defaultOptions
    ) {
        self.session = session
        self.options = options
    }

    public func request(_ api: Target) async throws -> Response {
        let request = api.request(for: options.baseUrl ?? api.baseUrl)
        let (data, response) = try await session.data(for: request, delegate: nil)
        return try .make(data: data, response: response)
    }
}

public extension TargetType {
    func request(for baseURL: URL) -> URLRequest {
        let string: String
        var httpBody: Data? = .none
        switch data {
        case .params(let params):
            if method == .GET {
                let query = params.enumerated().map({ "\($1.key)=\($1.value)" }).joined(separator: "&")
                string = "\(path)?\(query)"
            } else {
                string = path
            }
        case .data(let data):
            httpBody = data
            string = path
        case .plain:
            string = path
        case .encodable(let value):
            httpBody = try! JSONEncoder().encode(value)
            string = path
        }
        let url = URL(string: baseURL.absoluteString + string)!
        var request =  URLRequest(url: url)
        request.httpBody = httpBody
        request.httpMethod = method.rawValue
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.cachePolicy = cachePolicy
        return request
    }
}
