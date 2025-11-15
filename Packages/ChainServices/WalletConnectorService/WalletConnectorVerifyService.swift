// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import ReownWalletKit

public protocol WalletConnectorVerifyServiceable: Sendable {
    func validateOrigin(
        metadata: WalletConnectionSessionAppMetadata,
        verifyContext: VerifyContext?
    ) -> WalletConnectionVerificationStatus
}

public struct WalletConnectorVerifyService: WalletConnectorVerifyServiceable {
    public init() {}

    public func validateOrigin(
        metadata: WalletConnectionSessionAppMetadata,
        verifyContext: VerifyContext?
    ) -> WalletConnectionVerificationStatus {
        guard let verifyContext else {
            return .unknown
        }

        let metadataURL = extractDomain(from: metadata.url)
        let verifiedOrigin = verifyContext.origin

        switch verifyContext.validation {
        case .valid:
            return validateVerifiedOrigin(
                metadataURL: metadataURL,
                verifiedOrigin: verifiedOrigin
            )
        case .scam: return .malicious
        case .invalid: return .invalid
        case .unknown: return .unknown
        }
    }
}

extension WalletConnectorVerifyService {
    private func validateVerifiedOrigin(
        metadataURL: String,
        verifiedOrigin: String?
    ) -> WalletConnectionVerificationStatus {
        guard let origin = verifiedOrigin else {
            return .invalid
        }

        let originDomain = extractDomain(from: origin)
        guard matchesDomain(metadataURL, originDomain) else {
            return .invalid
        }

        return .verified
    }

    private func extractDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return urlString
        }
        return host.lowercased()
    }

    private func matchesDomain(_ domain1: String, _ domain2: String) -> Bool {
        domain1.lowercased() == domain2.lowercased()
    }
}
