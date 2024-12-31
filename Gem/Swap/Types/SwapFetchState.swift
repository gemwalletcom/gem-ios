// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum SwapFetchState: Identifiable, Hashable {
    case idle
    case fetch(input: SwapQuoteInput, delay: Duration?)

    var delay: Duration? {
        switch self {
        case .idle: nil
        case let .fetch(_, delay): delay
        }
    }
}

// MARK: - Identifiable

extension SwapFetchState {
    var id: String {
        switch self {
        case .idle: "idle"
        case let .fetch(input, _): input.id
        }
    }
}
