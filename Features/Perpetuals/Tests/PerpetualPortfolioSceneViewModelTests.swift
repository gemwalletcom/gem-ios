// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import Components
import PerpetualsTestKit
@testable import Perpetuals

struct PerpetualPortfolioSceneViewModelTests {

    @Test
    @MainActor
    func navigationTitle() {
        #expect(PerpetualPortfolioSceneViewModel.mock().navigationTitle == "Account")
    }

    @Test
    @MainActor
    func chartTypeTitle() {
        let model = PerpetualPortfolioSceneViewModel.mock()
        #expect(model.chartTypeTitle(.value) == "Value")
        #expect(model.chartTypeTitle(.pnl) == "PnL")
    }

    @Test
    @MainActor
    func periods() {
        let model = PerpetualPortfolioSceneViewModel.mock()
        #expect(model.periods == [.day, .week, .month, .all])

        model.state = .data(.mock(day: .mock(), week: .mock(), month: nil, allTime: nil))
        #expect(model.periods == [.day, .week])
    }

    @Test
    @MainActor
    func chartState() {
        let model = PerpetualPortfolioSceneViewModel.mock()

        model.state = .loading
        #expect(model.chartState.isLoading)

        model.state = .noData
        #expect(model.chartState.isNoData)

        model.state = .error(AnyError("test"))
        #expect(model.chartState.isError)

        model.state = .data(.mock(day: .mock(accountValueHistory: ChartDateValue.mockHistory(values: [100, 100, 100]))))
        #expect(model.chartState.isNoData)

        model.state = .data(.mock(day: .mock(accountValueHistory: ChartDateValue.mockHistory(values: [100, 105, 110]))))
        #expect(model.chartState.value != nil)
    }

    @Test
    @MainActor
    func chartStateSigned() {
        let model = PerpetualPortfolioSceneViewModel.mock()
        model.state = .data(.mock(day: .mock(
            accountValueHistory: ChartDateValue.mockHistory(values: [100, 110]),
            pnlHistory: ChartDateValue.mockHistory(values: [0, 10])
        )))

        model.selectedChartType = .value
        if case .data(let chartModel) = model.chartState {
            #expect(chartModel.signed == false)
        }

        model.selectedChartType = .pnl
        if case .data(let chartModel) = model.chartState {
            #expect(chartModel.signed == true)
        }
    }
}
