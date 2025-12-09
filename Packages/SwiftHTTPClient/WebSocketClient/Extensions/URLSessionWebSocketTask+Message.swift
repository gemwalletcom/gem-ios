// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension URLSessionWebSocketTask.Message {
    var data: Data? {
        switch self {
        case .string(let text): text.data(using: .utf8)
        case .data(let data): data
        @unknown default: nil
        }
    }
}
