// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SiweMessage

public struct SiweMessageViewModel {
    private let message: SiweMessage

    public init(message: SiweMessage) {
        self.message = message
    }

    var domainText: String {
        message.domain
    }

    var addressText: String {
        message.address
    }

    var statementText: String? {
        message.statement?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }

    var detailItems: [(title: String, value: String)] {
        var items: [(String, String)] = [
            ("Domain", domainText),
            ("Address", addressText),
            ("URI", message.uri),
            ("Version", message.version),
            ("Chain ID", "\(message.chainId)"),
            ("Nonce", message.nonce),
            ("Issued At", message.issuedAt),
        ]

        if let scheme = message.scheme?.nilIfEmpty {
            items.insert(("Scheme", scheme), at: 1)
        }

        if let expiration = message.expirationTime?.nilIfEmpty {
            items.append(("Expiration Time", expiration))
        }

        if let notBefore = message.notBefore?.nilIfEmpty {
            items.append(("Not Before", notBefore))
        }

        if let requestId = message.requestId?.nilIfEmpty {
            items.append(("Request ID", requestId))
        }

        if let statement = statementText {
            items.append(("Statement", statement))
        }

        return items
    }

    var hasResources: Bool {
        !resources.isEmpty
    }

    var resources: [String] {
        message.resources
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
