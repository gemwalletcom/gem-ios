// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import Components

@testable import Contacts

@MainActor
struct ManageContactAddressViewModelTests {

    @Test
    func buttonStateAddModeEmptyAddress() {
        let model = ManageContactAddressViewModel.mock(mode: .add)

        #expect(model.buttonState == .disabled)
    }

    @Test
    func buttonStateAddModeValidAddress() {
        let model = ManageContactAddressViewModel.mock(mode: .add)
        model.addressInputModel.text = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
        model.addressInputModel.update()

        #expect(model.buttonState == .normal)
    }

    @Test
    func buttonStateEditModeNoChanges() {
        let model = ManageContactAddressViewModel.mock(mode: .edit(.mock(address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")))

        #expect(model.buttonState == .disabled)
    }

    @Test
    func buttonStateEditModeWithChanges() {
        let model = ManageContactAddressViewModel.mock(mode: .edit(.mock(address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")))
        model.memo = "new memo"

        #expect(model.buttonState == .normal)
    }

    @Test
    func showMemo() {
        let model = ManageContactAddressViewModel.mock(mode: .add)

        model.chain = .bitcoin
        #expect(model.showMemo == false)

        model.chain = .cosmos
        #expect(model.showMemo == true)
    }
}

// MARK: - Mock

extension ManageContactAddressViewModel {
    static func mock(
        contactId: String = "contact-1",
        mode: Mode
    ) -> ManageContactAddressViewModel {
        ManageContactAddressViewModel(
            contactId: contactId,
            mode: mode,
            onComplete: { _ in }
        )
    }
}
