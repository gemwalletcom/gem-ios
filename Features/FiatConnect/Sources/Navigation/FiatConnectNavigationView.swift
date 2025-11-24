// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import Components
import Localization

public struct FiatConnectNavigationView: View {
    @State private var model: FiatSceneViewModel

    public init(model: FiatSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        FiatScene(
            model: model
        )
        .observeQuery(
            request: $model.assetRequest,
            value: $model.assetData
        )
        .ifElse(
            model.showFiatTypePicker,
            ifContent: {
                $0.toolbar {
                    FiatTypeToolbar(selectedType: $model.type)
                }
            },
            elseContent: {
                $0.navigationTitle(model.title)
            }
        )
        .sheet(isPresented: $model.isPresentingFiatProvider) {
            SelectableListNavigationStack(
                model: model.fiatProviderViewModel,
                onFinishSelection: model.onSelectQuotes,
                listContent: { SimpleListItemView(model: $0) }
            )
        }
    }
}
