import Foundation

public struct ResponseError: Codable, Sendable {
    public let error: ResponseMessage

    public struct ResponseMessage: Codable, Sendable, Error {
        public let message: String
    }
}

public struct ResponseResult<T: Codable & Sendable>: Codable, Sendable {
    public let data: T

    public init(_ data: T) {
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        if let error = try? ResponseError(from: decoder) {
            throw error.error
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if try container.decodeNil(forKey: .data) {
            throw DecodingError.valueNotFound(
                T.self,
                .init(
                    codingPath: [CodingKeys.data],
                    debugDescription: "Expected non-null data but found null."
                )
            )
        }

        self.data = try container.decode(T.self, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }

    private enum CodingKeys: String, CodingKey {
        case data
    }
}
