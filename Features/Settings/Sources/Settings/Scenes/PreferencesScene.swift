// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents

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
                }
            }
            .listRowInsets(.assetListRowInsets)
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension PreferencesScene {
    private func onSelectLanguage() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
    }
}
