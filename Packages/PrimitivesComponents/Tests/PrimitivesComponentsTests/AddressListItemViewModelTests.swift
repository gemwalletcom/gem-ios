// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesComponents
import Primitives
import PrimitivesTestKit

struct AddressListItemViewModelTests {
    
    @Test("Subtitle includes name and address when name is different from address")
    func subtitleWithName() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil),
            style: .short,
            explorerService: MockExplorerLink()
        )
        
        #expect(model.subtitle == "Alice (0x12345...01112)")
    }

    @Test("Subtitle falls back to formatted address if name is nil")
    func subtitleWithoutName() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: nil, chain: .ethereum, address: "0x123456789101112", assetImage: nil),
            style: .full,
            explorerService: MockExplorerLink()
        )
        #expect(model.subtitle == "0x123456789101112")
    }
}
