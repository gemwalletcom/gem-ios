// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store

public struct FiatConnectNavigationView: View {
    @Binding private var navigationPath: NavigationPath

    @State private var model: FiatSceneViewModel
    
    public init(
        navigationPath: Binding<NavigationPath>,
        model: FiatSceneViewModel
    ) {
        _model = State(initialValue: model)
        _navigationPath = navigationPath

    }

    public var body: some View {
        FiatScene(model: model)
            .navigationDestination(for: Scenes.FiatProviders.self) { _ in
                FiatProvidersScene(
                    model: FiatProvidersViewModel(
                        type: model.input.type,
                        asset: model.asset,
                        quotes: model.state.value ?? [],
                        formatter: CurrencyFormatter(type: .currency, currencyCode: ""),
                        onSelectQuote: {
                            model.selectQuote($0)
                            navigationPath.removeLast()
                        }
                    )
                )
            }
    }
}
