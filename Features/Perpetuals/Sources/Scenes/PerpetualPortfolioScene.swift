// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import PrimitivesComponents

public struct PerpetualPortfolioScene: View {
    private let fetchTimer = Timer.publish(every: 60, tolerance: 1, on: .main, in: .common).autoconnect()
    @State private var model: PerpetualPortfolioSceneViewModel

    public init(model: PerpetualPortfolioSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            List {
                Section { } header: {
                    VStack {
                        Picker("", selection: $model.selectedChartType) {
                            ForEach(PortfolioChartType.allCases) { type in
                                Text(model.chartTypeTitle(type)).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, Spacing.medium)
                        .padding(.vertical, Spacing.small)

                        ChartStateView(
                            state: model.chartState,
                            selectedPeriod: $model.selectedPeriod,
                            periods: model.periods
                        )
                    }
                }
                .cleanListRow()

                Section(header: Text(model.infoSectionTitle)) {
                    ListItemView(title: model.unrealizedPnlTitle, subtitle: model.unrealizedPnlValue.text, subtitleStyle: model.unrealizedPnlValue.style)
                    ListItemView(title: model.allTimePnlTitle, subtitle: model.allTimePnlValue.text, subtitleStyle: model.allTimePnlValue.style)
                    ListItemView(title: model.volumeTitle, subtitle: model.volumeText)
                }
            }
            .navigationTitle(model.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarDismissItem(type: .close, placement: .cancellationAction)
            .task {
                await model.fetch()
            }
            .refreshable {
                await model.fetch()
            }
            .onReceive(fetchTimer) { _ in
                Task {
                    await model.fetch()
                }
            }
            .listSectionSpacing(.compact)
        }
    }
}
