// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import PrimitivesComponents

struct PerpetualPortfolioScene: View {
    @State private var model: PerpetualPortfolioSceneViewModel

    init(model: PerpetualPortfolioSceneViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
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

                Section(header: Text(model.infoSectionTitle)) {
                    ListItemView(title: model.unrealizedPnlTitle, subtitle: model.unrealizedPnlValue.text, subtitleStyle: model.unrealizedPnlValue.style)
                    ListItemView(title: model.accountLeverageTitle, subtitle: model.accountLeverageText)
                    ListItemView(title: model.marginUsageTitle, subtitle: model.marginUsageText)
                    ListItemView(title: model.allTimePnlTitle, subtitle: model.allTimePnlValue.text, subtitleStyle: model.allTimePnlValue.style)
                    ListItemView(title: model.volumeTitle, subtitle: model.volumeText)
                }
            }
            .navigationTitle(model.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("", selection: $model.selectedChartType) {
                            ForEach(PerpetualPortfolioChartType.allCases) { type in
                                Text(model.chartTypeTitle(type)).tag(type)
                            }
                        }
                    } label: {
                        Text(model.chartTypeTitle(model.selectedChartType))
                            .fontWeight(.semibold)
                    }
                }
            }
            .toolbarDismissItem(type: .close, placement: .cancellationAction)
            .task {
                await model.fetch()
            }
            .refreshable {
                await model.fetch()
            }
            .onTimer(every: .minute1) {
                await model.fetch()
            }
            .listSectionSpacing(.compact)
        }
    }
}
