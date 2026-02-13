import Testing
import Primitives
import PrimitivesTestKit
import PriceAlertServiceTestKit

@testable import PriceAlerts

@MainActor
struct SetPriceAlertViewModelTests {
    
    @Test
    func testPriceAlertDirection_up() async throws {
        let viewModel = SetPriceAlertViewModel.mock()
        viewModel.state.amount = "200.00"
        viewModel.setAlertDirection(for: .mock(price: 150))
        #expect(viewModel.state.alertDirection == .up)
        
        viewModel.state.amount = "200.02"
        viewModel.setAlertDirection(for: .mock(price: 200.01))
        #expect(viewModel.state.alertDirection == .up)
        
        viewModel.state.amount = "200.00"
        viewModel.setAlertDirection(for: .mock(price: 199.9))
        #expect(viewModel.state.alertDirection == .up)
    }

    @Test
    func testPriceAlertDirection_down() async throws {
        let viewModel = SetPriceAlertViewModel.mock()
        
        viewModel.state.amount = "200.00"
        viewModel.setAlertDirection(for: .mock(price: 250))
        #expect(viewModel.state.alertDirection == .down)
        
        viewModel.state.amount = "200,00"
        viewModel.setAlertDirection(for: .mock(price: 200.1))
        #expect(viewModel.state.alertDirection == .down)

        viewModel.state.amount = "199.99"
        viewModel.setAlertDirection(for: .mock(price: 200))
        #expect(viewModel.state.alertDirection == .down)
    }

    @Test
    func testPriceAlertDirection_none() async throws {
        let viewModel = SetPriceAlertViewModel.mock()
        viewModel.setAlertDirection(for: nil)
        #expect(viewModel.state.alertDirection == nil)
        
        viewModel.state.amount = "200,00"
        viewModel.setAlertDirection(for: .mock(price: 200.0))
        #expect(viewModel.state.alertDirection == nil)
    }
}

fileprivate extension SetPriceAlertViewModel {
    static func mock() -> SetPriceAlertViewModel {
        SetPriceAlertViewModel(
            walletId: WalletId.mock(),
            asset: .mock(),
            priceAlertService: .mock(),
            onComplete: { _ in }
        )
    }
}
