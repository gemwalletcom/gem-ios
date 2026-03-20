// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum FiatTransactionStatus: Codable, Equatable, Hashable, Sendable {
    case complete
    case pending
    case failed
    case unknown(String)

    private enum CodingKeys: String {
        case complete
        case pending
        case failed
    }

    public var rawValue: String {
        switch self {
        case .complete: CodingKeys.complete.rawValue
        case .pending: CodingKeys.pending.rawValue
        case .failed: CodingKeys.failed.rawValue
        case .unknown(let value): value
        }
    }

    public init(rawValue: String) {
        switch CodingKeys(rawValue: rawValue) {
        case .complete: self = .complete
        case .pending: self = .pending
        case .failed: self = .failed
        case .none: self = .unknown(rawValue)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(rawValue: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
