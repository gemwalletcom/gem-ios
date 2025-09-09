import Foundation

public struct ResponseError: Codable, Sendable, Error {
    public let error: String
    public init(error: String) { self.error = error }
}

public struct ResponseResult<T: Codable & Sendable>: Codable, Sendable {
    public let data: T

    public init(data: T) { self.data = data }

    private enum CodingKeys: String, CodingKey { case data, error }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        if let err = try c.decodeIfPresent(ResponseError.self, forKey: .error) {
            throw err
        }
        self.data = try c.decode(T.self, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encodeNil(forKey: .error)
    }
}
