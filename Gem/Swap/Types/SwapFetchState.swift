// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

enum SwapFetchState: Identifiable, Hashable {
    case idle
    case fetch(input: SwapQuoteInput, delay: Duration?)
    case data(quotes: [SwapQuote])

    var delay: Duration? {
        switch self {
        case .idle, .data: nil
        case let .fetch(_, delay): delay
        }
    }
}

// MARK: - Identifiable

extension SwapFetchState {
    var id: String {
        switch self {
        case .idle: "idle"
        case let .fetch(input, delay): input.id + (delay?.description ?? "")
        case let .data(quotes): quotes.map({ String($0.hashValue) }).joined(separator: "_")
        }
    }
}
