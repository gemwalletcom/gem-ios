// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI

public struct AppReleaseService: Sendable {
    private let configService: any GemAPIConfigService
    
    public init(configService: any GemAPIConfigService = GemAPIService()) {
        self.configService = configService
    }
    
    public var releaseVersion: String {
        Bundle.main.releaseVersionNumber
    }
    
    public func getNewestRelease() async throws -> Release? {
        release(try await configService.getConfig())
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
