// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization

public struct ChartStateView: View {
    private let state: StateViewType<ChartValuesViewModel>
    private let periods: [ChartPeriod]

    @Binding private var selectedPeriod: ChartPeriod

    public init(
        state: StateViewType<ChartValuesViewModel>,
        selectedPeriod: Binding<ChartPeriod>,
        periods: [ChartPeriod] = [.hour, .day, .week, .month, .year, .all]
    ) {
        self.state = state
        self._selectedPeriod = selectedPeriod
        self.periods = periods
    }

    public var body: some View {
        VStack {
            VStack {
                switch state {
                case .noData:
                    StateEmptyView(title: Localized.Common.notAvailable , image: Images.EmptyContent.activity)
                case .loading:
                    LoadingView()
                case .data(let model):
                    ChartView(model: model)
                case .error(let error):
                    StateEmptyView(
                        title: error.networkOrNoDataDescription,
                        image: Images.ErrorConent.error
                    )
                }
            }
            .frame(height: 320)

            PeriodSelectorView(selectedPeriod: $selectedPeriod, periods: periods)
        }
    }
}
