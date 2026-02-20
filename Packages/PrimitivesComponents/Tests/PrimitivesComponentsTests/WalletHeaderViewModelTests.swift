import Testing
import Primitives
import PrimitivesTestKit

@testable import PrimitivesComponents

struct WalletHeaderViewModelTests {

    @Test
    func title() {
        let model = WalletHeaderViewModel(
            walletType: .multicoin,
            totalValue: .mock(value: 1000),
            currencyCode: Currency.usd.rawValue,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: [])
        )
        #expect(model.title == "$1,000.00")
    }

    @Test
    func subtitle() {
        let model = WalletHeaderViewModel(
            walletType: .multicoin,
            totalValue: .mock(value: 1000, pnlAmount: 50, pnlPercentage: 5),
            currencyCode: Currency.usd.rawValue,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: [])
        )
        #expect(model.subtitle == "+$50.00 (5.00%)")
    }

    @Test
    func buttonsDisabled() {
        let model = WalletHeaderViewModel(
            walletType: .multicoin,
            totalValue: .mock(),
            currencyCode: Currency.usd.rawValue,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: [.activateAsset, .accountBlockedMultiSignature])
        )
        #expect(model.buttons.allSatisfy { !$0.isEnabled })
    }
}
