// Copyright (c). Gem Wallet. All rights reserved.

import Testing

@testable import PrimitivesComponents

struct HeaderBannerEventViewModelTests {

    @Test func testIsEnabled() {
        #expect(HeaderBannerEventViewModel(events: [.stake]).isButtonsEnabled == true)
        #expect(HeaderBannerEventViewModel(events: [.enableNotifications]).isButtonsEnabled == true)
        #expect(HeaderBannerEventViewModel(events: [.accountActivation]).isButtonsEnabled == true)
        #expect(HeaderBannerEventViewModel(events: [.accountActivation, .activateAsset]).isButtonsEnabled == false)
        #expect(HeaderBannerEventViewModel(events: [.stake, .activateAsset]).isButtonsEnabled == false)
        #expect(HeaderBannerEventViewModel(events: [.accountBlockedMultiSignature]).isButtonsEnabled == false)
    }
}
