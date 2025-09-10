import Foundation

public struct ResponseError: Codable, Sendable {
    let error: ResponseMessage
    
    public struct ResponseMessage: Codable, Sendable, Error {
        public let message: String
    }
}

public struct ResponseResult<T: Codable & Sendable>: Codable, Sendable {
    public let data: T

    public init(_ data: T) { self.data = data }

    public init(from decoder: Decoder) throws {
        if let error = try? ResponseError(from: decoder) {
            throw error.error
        }
        self.data = try T(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
    }
}
