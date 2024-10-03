import Foundation
import Combine

public struct Response {
    public let code: Int
    public let body: Data
    public let headers: [String: String]

    public init(code: Int, body: Data, headers: [String : String]) {
        self.code = code
        self.body = body
        self.headers = headers
    }

    public static let standardDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        return decoder
    }()


    public static func make(data: Data, response urlResponse: URLResponse?) throws -> Response {
        guard
            let response = urlResponse as? HTTPURLResponse,
            let headers = response.allHeaderFields as? [String: String]
        else {
            throw URLError(.badServerResponse)
        }
        return Response(code: response.statusCode, body: data, headers: headers)
    }

    public func map<T: Decodable>(as type: T.Type, _ decoder: JSONDecoder = Self.standardDecoder) throws -> T {
        return try decoder.decode(type, from: body)
    }

    public func mapOrError<T: Decodable, E: Decodable & LocalizedError>(as type: T.Type, asError: E.Type, _ decoder: JSONDecoder = Self.standardDecoder) throws -> T {
        do {
            return try decoder.decode(type, from: body)
        } catch {
            throw try decoder.decode(asError, from: body)
        }
    }

    public func mapOrCatch<T: Decodable>(as type: T.Type, codes: [Int], result: T, _ decoder: JSONDecoder = Self.standardDecoder) throws -> T {
        if codes.contains(code) {
            return result
        }
        return try decoder.decode(type, from: body)
    }
}

extension Formatter {
    nonisolated(unsafe) public static let customISO8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    nonisolated(unsafe) public static let customISO8601DateFormatterNoSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601WithFractionalSeconds = custom { decoder in
        let dateStr = try decoder.singleValueContainer().decode(String.self)
        if let date = Formatter.customISO8601DateFormatter.date(from: dateStr) {
            return date
        }
        if let date = Formatter.customISO8601DateFormatterNoSeconds.date(from: dateStr) {
            return date
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid date"))
    }
}
