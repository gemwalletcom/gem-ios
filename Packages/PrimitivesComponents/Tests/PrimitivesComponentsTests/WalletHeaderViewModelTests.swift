import Testing
import Primitives

@testable import PrimitivesComponents

struct WalletHeaderViewModelTests {

    @Test
    func testTotalValue() {
        #expect(
            WalletHeaderViewModel(
                walletType: .multicoin,
                value: 1000,
                currencyCode: Currency.usd.rawValue,
                bannerEventsViewModel: HeaderBannerEventViewModel(events: []))
            .totalValueText == "$1,000.00"
        )
    }

    @Test
    func buttonsDisabledWithActivateAssetEvent() {
        let model = WalletHeaderViewModel(
            walletType: .multicoin,
            value: 1000,
            currencyCode: Currency.usd.rawValue,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: [.activateAsset, .accountBlockedMultiSignature])
        )
        
        #expect(model.buttons.allSatisfy { !$0.isEnabled })
    }
}
