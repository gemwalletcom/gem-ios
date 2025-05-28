// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import Preferences
import GemstonePrimitives
import Components
import PrimitivesComponents
import AppService
import Primitives

@Observable
@MainActor
public final class AboutUsViewModel: Sendable {
    private let preferences: ObservablePreferences
    private let releaseService: AppReleaseService

    public init(
        preferences: ObservablePreferences,
        releaseService: AppReleaseService
    ) {
        self.preferences = preferences
        self.releaseService = releaseService
    }

    var title: String { Localized.Settings.aboutus }

    var termsOfServiceTitle: String { Localized.Settings.termsOfServices }
    var termsOfServiceURL: URL { PublicConstants.url(.termsOfService) }

    var privacyPolicyTitle: String { Localized.Settings.privacyPolicy }
    var privacyPolicyURL: URL { PublicConstants.url(.privacyPolicy) }

    var websiteTitle: String { Localized.Settings.website }
    var websiteURL: URL { PublicConstants.url(.website) }

    var versionTextTitle: String { Localized.Settings.version }
    var versionTextValue: String {
        let version = Bundle.main.releaseVersionNumber
        let number = Bundle.main.buildVersionNumber
        return "\(version) (\(number))"
    }
    var versionTextImage: AssetImage { AssetImage.image(Images.Settings.version) }

    var contextDevTitle: String {
        if preferences.isDeveloperEnabled {
            Localized.Settings.disableValue(Localized.Settings.developer)
        } else {
            Localized.Settings.enableValue(Localized.Settings.developer)
        }
    }
    var contextDeveloperImage: String { SystemImage.info }

    var contextMenuItems: [ContextMenuItemType] {
        [
            .copy(value: versionTextValue),
            .custom(
                title: contextDevTitle,
                systemImage: contextDeveloperImage,
                action: toggleDeveloperMode
            )
        ]
    }
    
    var release: Release?
    var releaseVersion: String? {
        release?.version
    }
    var appStoreLink: String {
        PublicConstants.url(.appStore).absoluteString
    }
    var updateText: String {
        "**[\(Localized.UpdateApp.action)](\(appStoreLink))**"
    }
}

extension AboutUsViewModel {
    func toggleDeveloperMode() {
        preferences.isDeveloperEnabled.toggle()
    }
    
    func fetch() async {
        do {
            release = try await releaseService.getNewestRelease()
        } catch {
            NSLog("Release fetch failed: \(error)")
        }
    }
}
