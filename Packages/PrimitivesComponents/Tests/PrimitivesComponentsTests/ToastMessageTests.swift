// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Style
import Components
@testable import PrimitivesComponents

struct ToastMessageTests {

    @Test
    func copy() {
        #expect(ToastMessage.copy("Copied").image == SystemImage.copy)
    }

    @Test
    func pinned() {
        #expect(ToastMessage.pinned("BTC", isPinned: true).image == SystemImage.pin)
        #expect(ToastMessage.pinned("BTC", isPinned: false).image == SystemImage.unpin)
    }

    @Test
    func addedToWallet() {
        #expect(ToastMessage.addedToWallet().image == SystemImage.plusCircle)
    }

    @Test
    func priceAlert() {
        #expect(ToastMessage.priceAlert(for: "ETH", enabled: true).image == SystemImage.bellFill)
        #expect(ToastMessage.priceAlert(message: "Alert set").image == SystemImage.bellFill)
    }

    @Test
    func success() {
        #expect(ToastMessage.success("Saved").image == SystemImage.checkmark)
    }
}
