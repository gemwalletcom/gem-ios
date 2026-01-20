// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WebViewDomainPolicy: Sendable {
    public let allowedDomains: [String]
    public let openExternalLinksInSafari: Bool

    public init(allowedDomains: [String], openExternalLinksInSafari: Bool) {
        self.allowedDomains = allowedDomains
        self.openExternalLinksInSafari = openExternalLinksInSafari
    }
}

extension URL {
    public func isAllowed(by policy: WebViewDomainPolicy) -> Bool {
        isDomainAllowed(policy.allowedDomains)
    }
}
