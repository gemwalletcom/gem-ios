// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesComponents
import Primitives
import Components

struct AddressListItemViewModelTests {
    
    @Test
    func subtitleWithName() {
        let model = AddressListItemViewModel.mock()
        #expect(model.subtitle == "Alice (0x12345...01112)")
    }

    @Test
    func subtitleWithoutAddress() {
        let account = SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: AssetImage())
        let model = AddressListItemViewModel.mock(account: account)
        #expect(model.subtitle == "Alice")
    }
    
    @Test
    func subtitleWithoutName() {
        let account = SimpleAccount(name: nil, chain: .ethereum, address: "0x123456789101112", assetImage: nil)
        let model = AddressListItemViewModel.mock(account: account, mode: .auto(addressStyle: .full))
        #expect(model.subtitle == "0x123456789101112")
    }

    @Test
    func subtitleAddressMode() {
        let model = AddressListItemViewModel.mock(mode: .address(addressStyle: .short))
        #expect(model.subtitle == "0x12345...01112")
    }

    @Test
    func subtitleNameOrAddressWithName() {
        let model = AddressListItemViewModel.mock(mode: .nameOrAddress)
        #expect(model.subtitle == "Alice")
    }

    @Test
    func subtitleNameOrAddressWithoutName() {
        let account = SimpleAccount(name: nil, chain: .ethereum, address: "0x123456789101112", assetImage: nil)
        let model = AddressListItemViewModel.mock(account: account, mode: .nameOrAddress)
        #expect(model.subtitle == "0x123456789101112")
    }
}

extension AddressListItemViewModel {
    static func mock(
        title: String = "Recipient",
        account: SimpleAccount = SimpleAccount(name: "Alice", chain: .ethereum, address: "0x123456789101112", assetImage: nil),
        mode: Mode = .auto(addressStyle: .short),
        addressLink: BlockExplorerLink = .init(name: "Mock", link: "https://mock.com")
    ) -> AddressListItemViewModel {
        AddressListItemViewModel(
            title: title,
            account: account,
            mode: mode,
            addressLink: addressLink
        )
    }
}
