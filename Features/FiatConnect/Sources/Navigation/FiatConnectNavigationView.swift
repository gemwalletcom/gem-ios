// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import Components
import Localization

public struct FiatConnectNavigationView: View {
    @State private var model: FiatSceneViewModel
    @State private var isPresentingFiatProviderSelect: Bool = false

    public init(model: FiatSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        FiatScene(
            model: model,
            isPresentingFiatProviderSelect: $isPresentingFiatProviderSelect
        )
        .sheet(isPresented: $isPresentingFiatProviderSelect) {
            SelectableListNavigationView(
                model: model.fiatProviderViewModel(),
                onFinishSelection: onSelectQuote,
                listContent: { SimpleListItemView(model: $0) }
            )
        }
    }
}

// MARK: - Actions

extension FiatConnectNavigationView {
    func onSelectQuote(_ quotes: [FiatQuoteViewModel]) {
        guard let quoteModel = quotes.first else { return }
        model.selectQuote(quoteModel.quote)
        isPresentingFiatProviderSelect = false
    }
}
