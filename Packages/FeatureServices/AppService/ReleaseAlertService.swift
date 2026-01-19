// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemstonePrimitives
import Preferences
import Primitives
import UIKit

public struct ReleaseAlertService: Sendable {
    private let appReleaseService: AppReleaseService
    private let preferences: Preferences

    public init(
        appReleaseService: AppReleaseService,
        preferences: Preferences
    ) {
        self.appReleaseService = appReleaseService
        self.preferences = preferences
    }

    public func checkForUpdate() async -> Release? {
        guard let release = await appReleaseService.getNewestRelease(),
              preferences.skippedReleaseVersion != release.version
        else { return nil }
        return release
    }

    public func skipRelease(_ release: Release) {
        preferences.skippedReleaseVersion = release.version
    }

    @MainActor
    public func openAppStore() {
        UIApplication.shared.open(PublicConstants.url(.appStore))
    }
}
