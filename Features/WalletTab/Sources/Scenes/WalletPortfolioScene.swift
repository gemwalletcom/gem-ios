// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import PrimitivesComponents

public struct WalletPortfolioScene: View {
    @State private var model: WalletPortfolioSceneViewModel

    public init(model: WalletPortfolioSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            List {
                Section { } header: {
                    ChartStateView(
                        state: model.chartState,
                        selectedPeriod: $model.selectedPeriod,
                        periods: model.periods
                    )
                }
                .cleanListRow()
            }
            .navigationTitle(model.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarDismissItem(type: .close, placement: .cancellationAction)
            .task {
                await model.fetch()
            }
            .onChange(of: model.selectedPeriod) {
                Task { await model.fetch() }
            }
            .listSectionSpacing(.compact)
        }
    }
}
