// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import Components
import Localization

public struct FiatConnectNavigationView: View {
    @State private var model: FiatSceneViewModel
    @State private var isPresentingFiatProviderSelect: Bool?

    public init(model: FiatSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        FiatScene(
            model: model,
            isPresentingFiatProviderSelect: $isPresentingFiatProviderSelect
        )
        .sheet(presenting: $isPresentingFiatProviderSelect) { _ in
            NavigationStack {
                SelectableListView(
                    model: .constant(model.fiatProviderViewModel()),
                    onFinishSelection: onSelectQuote,
                    listContent: { SimpleListItemView(model: $0) }
                )
                .navigationTitle(Localized.Buy.Providers.title)
                .navigationBarTitleDisplayMode(.inline)
                .presentationDetents([.medium, .large])
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingFiatProviderSelect = nil
                        }.bold()
                    }
                }
            }
        }
    }
}

// MARK: - Actions

extension FiatConnectNavigationView {
    func onSelectQuote(_ quotes: [FiatQuoteViewModel]) {
        guard let quoteModel = quotes.first else { return }
        model.selectQuote(quoteModel.quote)
        isPresentingFiatProviderSelect = nil
    }
}
