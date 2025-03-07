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

public extension Provider where T: BatchTargetType {
    func requestBatch(_ targets: [T]) async throws -> Response {
        let encoder = JSONEncoder()
        let reqs = targets.enumerated().compactMap { index, element -> [String: Any]? in
            guard case .encodable(let req) = element.data else { return nil }
            // make sure id is unique in the batch
            var json = try? JSONSerialization.jsonObject(with: encoder.encode(req)) as? [String: Any]
            json?["id"] = index + 1
            return json
        }
        let payload = try JSONSerialization.data(withJSONObject: reqs)

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
