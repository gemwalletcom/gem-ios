// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
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
    var isPresentingAutoclosePicker = false

    public init(
        currencyModel: CurrencySceneViewModel,
        preferences: ObservablePreferences = .default
    ) {
        self.currencyModel = currencyModel
        self.preferences = preferences
    }

    var title: String { Localized.Settings.Preferences.title }

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

    var perpetualAutocloseType: PerpetualOrderType {
        get { PerpetualOrderType(rawValue: preferences.perpetualAutocloseType) ?? .market }
        set { preferences.perpetualAutocloseType = newValue.rawValue }
    }
    var defaultAutocloseTitle: String { Localized.Perpetual.autoClose }
    var defaultAutocloseValue: String { PerpetualOrderTypeViewModel(perpetualAutocloseType).title }
    var autocloseOptions: [PerpetualOrderTypeViewModel] { [.market, .limit].map { PerpetualOrderTypeViewModel($0) } }
}

// MARK: - Actions

extension PreferencesViewModel {
    func onSelectLeverage() {
        isPresentingLeveragePicker = true
    }

    func onSelectAutoclose() {
        isPresentingAutoclosePicker = true
    }
}
