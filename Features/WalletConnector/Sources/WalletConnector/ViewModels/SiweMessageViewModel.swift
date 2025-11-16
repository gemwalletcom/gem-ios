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

    var websiteText: String {
        message.uri
    }

    var addressText: String {
        message.address
    }

    var statementText: String? {
        message.statement?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }

    var hasResources: Bool {
        !resources.isEmpty
    }

    var resources: [String] {
        message.resources.compactMap { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
