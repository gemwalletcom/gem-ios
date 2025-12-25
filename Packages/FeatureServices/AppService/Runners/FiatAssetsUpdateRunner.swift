// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences
import AssetsService

public struct FiatAssetsUpdateRunner: OnstartAsyncRunnable {
    private let importAssetsService: ImportAssetsService
    private let preferences: Preferences

    public init(
        importAssetsService: ImportAssetsService,
        preferences: Preferences
    ) {
        self.importAssetsService = importAssetsService
        self.preferences = preferences
    }

    public func run(config: ConfigResponse?) async throws {
        guard let versions = config?.versions, shouldRun(versions: versions) else { return }
        try await importAssetsService.updateFiatAssets()
        debugLog("Updated fiat assets: on ramp \(versions.fiatOnRampAssets), off ramp \(versions.fiatOffRampAssets)")
    }

    private func shouldRun(versions: ConfigVersions) -> Bool {
        versions.fiatOnRampAssets > preferences.fiatOnRampAssetsVersion ||
        versions.fiatOffRampAssets > preferences.fiatOffRampAssetsVersion
    }
}
