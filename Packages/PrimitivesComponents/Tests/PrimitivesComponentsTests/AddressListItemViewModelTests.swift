// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesComponents
import Primitives
import PrimitivesTestKit
import Components

struct AddressListItemViewModelTests {
    
    @Test
    func subtitleWithName() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil),
            mode: .auto(addressStyle: .short),
            explorerService: MockExplorerLink()
        )
        
        #expect(model.subtitle == "Alice (0x12345...01112)")
    }

    @Test
    func subtitleWithoutAddress() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: AssetImage()),
            mode: .auto(addressStyle: .short),
            explorerService: MockExplorerLink()
        )
        
        #expect(model.subtitle == "Alice")
    }
    
    @Test
    func subtitleWithoutName() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: nil, chain: .ethereum, address: "0x123456789101112", assetImage: nil),
            mode: .auto(addressStyle: .full),
            explorerService: MockExplorerLink()
        )
        #expect(model.subtitle == "0x123456789101112")
    }

    @Test
    func subtitleAddressMode() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil),
            mode: .address(addressStyle: .short),
            explorerService: MockExplorerLink()
        )
        #expect(model.subtitle == "0x12345...01112")
    }

    @Test
    func subtitleNameOrAddressWithName() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil),
            mode: .nameOrAddress,
            explorerService: MockExplorerLink()
        )
        #expect(model.subtitle == "Alice")
    }

    @Test
    func subtitleNameOrAddressWithoutName() {
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: SimpleAccount(name: nil, chain: .ethereum, address: "0x123456789101112", assetImage: nil),
            mode: .nameOrAddress,
            explorerService: MockExplorerLink()
        )
        #expect(model.subtitle == "0x123456789101112")
    }
}
