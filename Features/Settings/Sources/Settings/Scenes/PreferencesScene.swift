// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents
import Style

public struct PreferencesScene: View {
    @Environment(\.openURL) private var openURL

    @State private var model: PreferencesViewModel

    public init(model: PreferencesViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Group {
                Section {
                    NavigationLink(value: Scenes.Currency()) {
                        ListItemView(
                            title: model.currencyTitle,
                            subtitle: model.currencyValue,
                            imageStyle: .settings(assetImage: model.currencyImage)
                        )
                    }

                    NavigationCustomLink(
                        with: ListItemView(
                            title: model.languageTitle,
                            subtitle: model.languageValue,
                            imageStyle: .settings(assetImage: model.languageImage)
                        ),
                        action: onSelectLanguage
                    )

                    if model.supportsAlternateIcons {
                        NavigationLink(value: Scenes.AppIcon()) {
                            ListItemView(
                                title: model.appIconTitle,
                                imageStyle: .settings(assetImage: model.appIconImage)
                            )
                        }
                    }

                    NavigationLink(value: Scenes.Chains()) {
                        ListItemView(
                            title: model.networksTitle,
                            imageStyle: .settings(assetImage: model.networksImage)
                        )
                    }
                }
                Section {
                    ListItemToggleView(
                        isOn: $model.isPerpetualEnabled,
                        title: model.perpetualsTitle,
                        imageStyle: .settings(assetImage: model.perpetualsImage)
                    )

                    if model.isPerpetualEnabled {
                        NavigationCustomLink(
                            with: ListItemView(
                                title: model.defaultLeverageTitle,
                                subtitle: model.defaultLeverageValue
                            ),
                            action: model.onSelectLeverage
                        )
                        .padding(.leading, Sizing.image.asset - .tiny)
                    }
                }
            }
            .listRowInsets(.assetListRowInsets)
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .sheet(isPresented: $model.isPresentingLeveragePicker) {
            LeveragePickerSheet(
                title: model.defaultLeverageTitle,
                leverageOptions: model.leverageOptions,
                selectedLeverage: $model.perpetualLeverage
            )
        }
    }
}

// MARK: - Actions

extension PreferencesScene {
    private func onSelectLanguage() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            openURL(settingsURL)
        }
    }
}
