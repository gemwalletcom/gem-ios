// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Style
import Localization
import Preferences

class AboutUsViewModel {

    let preferences: Preferences

    init(
        preferences: Preferences = .standard
    ) {
        self.preferences = preferences
        self.isDeveloperEnabled = preferences.isDeveloperEnabled
    }

    var isDeveloperEnabled: Bool {
        didSet { preferences.isDeveloperEnabled = isDeveloperEnabled }
    }

    var versionTextTitle: String { Localized.Settings.version }
    var versionTextValue: String {
        let version = Bundle.main.releaseVersionNumber
        let number = Bundle.main.buildVersionNumber
        return "\(version) (\(number))"
    }
    var versionTextImage: Image { Images.Settings.version }

    var contextDevTitle: String { Localized.Settings.enableValue(Localized.Settings.developer) }
    var contextDeveloperImage: String { SystemImage.info }
}
