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
        let account = SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil)
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: account,
            mode: .auto(addressStyle: .short),
            addressLink: MockExplorerLink().addressUrl(chain: account.chain, address: account.address)
        )
        
        #expect(model.subtitle == "Alice (0x12345...01112)")
    }

    @Test
    func subtitleWithoutAddress() {
        let account = SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: AssetImage())
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: account,
            mode: .auto(addressStyle: .short),
            addressLink: MockExplorerLink().addressUrl(chain: account.chain, address: account.address)
        )
        
        #expect(model.subtitle == "Alice")
    }
    
    @Test
    func subtitleWithoutName() {
        let account = SimpleAccount(name: nil, chain: .ethereum, address: "0x123456789101112", assetImage: nil)
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: account,
            mode: .auto(addressStyle: .full),
            addressLink: MockExplorerLink().addressUrl(chain: account.chain, address: account.address)
        )
        #expect(model.subtitle == "0x123456789101112")
    }

    @Test
    func subtitleAddressMode() {
        let account = SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil)
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: account,
            mode: .address(addressStyle: .short),
            addressLink: MockExplorerLink().addressUrl(chain: account.chain, address: account.address)
        )
        #expect(model.subtitle == "0x12345...01112")
    }

    @Test
    func subtitleNameOrAddressWithName() {
        let account = SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil)
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: account,
            mode: .nameOrAddress,
            addressLink: MockExplorerLink().addressUrl(chain: account.chain, address: account.address)
        )
        #expect(model.subtitle == "Alice")
    }

    @Test
    func subtitleNameOrAddressWithoutName() {
        let account = SimpleAccount(name: nil, chain: .ethereum, address: "0x123456789101112", assetImage: nil)
        let model = AddressListItemViewModel(
            title: "Recipient",
            account: account,
            mode: .nameOrAddress,
            addressLink: MockExplorerLink().addressUrl(chain: account.chain, address: account.address)
        )
        #expect(model.subtitle == "0x123456789101112")
    }
}
