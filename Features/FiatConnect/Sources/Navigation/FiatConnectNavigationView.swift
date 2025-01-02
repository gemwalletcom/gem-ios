// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store

public struct FiatConnectNavigationView: View {
    @Binding var navigationPath: NavigationPath

    private let model: FiatSceneViewModel

    public init(
        model: FiatSceneViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        self.model = model
        _navigationPath = navigationPath
    }

    public var body: some View {
        FiatScene(model: model)
            .navigationDestination(for: FiatConnectScenes.Providers.self) { _ in
                FiatProvidersScene(
                    model: FiatProvidersViewModel(
                        type: model.input.type,
                        asset: model.asset,
                        quotes: model.state.value ?? [],
                        formatter: CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency),
                        onSelectQuote: {
                            model.onSelectQuote($0)
                            navigationPath.removeLast()
                        }
                    )
                )
            }
    }
}
