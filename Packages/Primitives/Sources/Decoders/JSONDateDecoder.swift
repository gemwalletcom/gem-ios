// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct JSONDateDecoder {
    public static let standard = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        return decoder
    }()
}

public extension Formatter {
    nonisolated(unsafe) static let customISO8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    nonisolated(unsafe) static let customISO8601DateFormatterNoSeconds: ISO8601DateFormatter = {
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
