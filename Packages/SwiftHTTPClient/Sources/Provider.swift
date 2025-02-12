import Foundation

public protocol ProviderType: Sendable {
    associatedtype Target: TargetType
}
public protocol BatchTargetType: TargetType {}

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
        let request = TargetRequestBuilder(
            baseUrl: options.baseUrl ?? api.baseUrl,
            method: api.method,
            path: api.path,
            data: api.data,
            contentType: api.contentType,
            cachePolicy: api.cachePolicy
        ).build()
        let (data, response) = try await session.data(for: request, delegate: nil)
        return try .make(data: data, response: response)
    }
}

extension Provider where T: BatchTargetType {
    public func requestBatch(_ targets: [T]) async throws -> Response {
        let encoder = JSONEncoder()
        let payload = try JSONSerialization.data(withJSONObject: targets.compactMap {
            guard case .encodable(let req) = $0.data else { return nil }
            return try? encoder.encode(req)
        }.compactMap {
            try? JSONSerialization.jsonObject(with: $0)
        })
        guard let baseUrl = options.baseUrl else {
            throw ProviderError.missingBaseUrl
        }
        // Predefined method, path, improve if needed
        let request = TargetRequestBuilder(
            baseUrl: baseUrl,
            method: .POST,
            path: "",
            data: .data(payload),
            contentType: ContentType.json.rawValue,
            cachePolicy: .useProtocolCachePolicy
        ).build()

        let (data, response) = try await session.data(for: request, delegate: nil)
        return try .make(data: data, response: response)
    }
}
