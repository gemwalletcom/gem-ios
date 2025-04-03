// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import Preferences
import GemstonePrimitives
import Components

public struct AboutUsViewModel {
    private let preferences: ObservablePreferences

    public init(preferences: ObservablePreferences) {
        self.preferences = preferences
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
}

extension AboutUsViewModel {
    func toggleDeveloperMode() {
        preferences.isDeveloperEnabled.toggle()
    }
}
