// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit
import SwiftUI
import Localization
import Primitives
import Style
import Components
import Preferences
import PrimitivesComponents

@Observable
@MainActor
public final class PreferencesViewModel {
    private let preferences: ObservablePreferences
    private let currencyModel: CurrencySceneViewModel

    var isPresentingLeveragePicker = false

    public init(
        currencyModel: CurrencySceneViewModel,
        preferences: ObservablePreferences = .default
    ) {
        self.currencyModel = currencyModel
        self.preferences = preferences
    }

    var title: String { Localized.Settings.Preferences.title }

    var appIconTitle: String { Localized.Settings.Preferences.appIcon }
    var appIconImage: AssetImage { AssetImage.image(Images.Settings.gem) }
    var supportsAlternateIcons: Bool { UIApplication.shared.supportsAlternateIcons }

    var currencyTitle: String { Localized.Settings.currency }
    var currencyValue: String { currencyModel.selectedCurrencyValue }
    var currencyImage: AssetImage { AssetImage.image(Images.Settings.currency) }

    var languageTitle: String { Localized.Settings.language }
    var languageValue: String {
        guard let code = Locale.current.language.languageCode?.identifier else {
            return ""
        }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }
    var languageImage: AssetImage { AssetImage.image(Images.Settings.language) }

    var networksTitle: String { Localized.Settings.Networks.title }
    var networksImage: AssetImage { AssetImage.image(Images.Settings.networks) }

    var isPerpetualEnabled: Bool {
        get { preferences.isPerpetualEnabled }
        set { preferences.isPerpetualEnabled = newValue }
    }
    var perpetualsTitle: String { Localized.Perpetuals.title }
    var perpetualsImage: AssetImage { AssetImage.image(Images.Settings.perpetuals) }

    var perpetualLeverage: LeverageOption {
        get { LeverageOption(value: preferences.perpetualLeverage) }
        set { preferences.perpetualLeverage = newValue.value }
    }
    var defaultLeverageTitle: String { Localized.Settings.Preferences.defaultLeverage }
    var defaultLeverageValue: String { "\(preferences.perpetualLeverage)x" }
    var leverageOptions: [LeverageOption] { LeverageOption.allOptions }
}

// MARK: - Actions

extension PreferencesViewModel {
    func onSelectLeverage() {
        isPresentingLeveragePicker = true
    }
}
