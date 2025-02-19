// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import Components
import Localization

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
                SelectableListView(
                    model: .constant(model.fiatProviderViewModel()),
                    onFinishSelection: onSelectQuote,
                    listContent: { SimpleListItemView(model: $0) }
                )
                .navigationTitle(Localized.Buy.Providers.title)
            }
    }
}

// MARK: - Actions

extension FiatConnectNavigationView {
    func onSelectQuote(_ list: [FiatQuoteViewModel]) {
        guard let quoteModel = list.first else { return }
        model.selectQuote(quoteModel.quote)
        navigationPath.removeLast()
    }
}
