// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AppReleaseService: Sendable {
    private let configService: ConfigService

    public init(configService: ConfigService) {
        self.configService = configService
    }

    public var releaseVersion: String {
        Bundle.main.releaseVersionNumber
    }

    public func getNewestRelease() throws -> Release? {
        try configService.getConfig().flatMap { release($0) }
    }

    public func release(_ config: ConfigResponse) -> Release? {
        guard
            let release = config.releases.first(where: { $0.store == .appStore }),
            VersionCheck.isVersionHigher(new: release.version, current: releaseVersion)
        else {
            return nil
        }
        return release
    }
}
