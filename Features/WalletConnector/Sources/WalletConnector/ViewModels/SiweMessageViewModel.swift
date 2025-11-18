// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SiweMessage

public struct SiweMessageViewModel {
    private let message: SiweMessage

    public init(message: SiweMessage) {
        self.message = message
    }

    var detailItems: [(title: String, value: String)] {
        [
            ("Domain", message.domain),
            ("Address", message.address),
            ("URI", message.uri),
            ("Chain ID", "\(message.chainId)"),
            ("Nonce", message.nonce),
            ("Issued At", message.issuedAt),
            ("Version", message.version),
        ]
    }
}
