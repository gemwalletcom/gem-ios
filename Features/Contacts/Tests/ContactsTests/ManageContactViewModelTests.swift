// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import ContactService
import ContactServiceTestKit
import Components

@testable import Contacts

@MainActor
struct ManageContactViewModelTests {

    @Test
    func buttonStateAddModeEmptyName() {
        let model = ManageContactViewModel.mock(mode: .add)

        #expect(model.buttonState == .disabled)
    }

    @Test
    func buttonStateAddMode() {
        let model = ManageContactViewModel.mock(mode: .add)
        model.nameInputModel.text = "John"

        #expect(model.buttonState == .disabled)

        model.addresses = [.mock()]

        #expect(model.buttonState == .normal)
    }

    @Test
    func buttonStateEditMode() {
        let model = ManageContactViewModel.mock(mode: .edit(.mock(contact: .mock(name: "John"), addresses: [.mock()])))

        #expect(model.buttonState == .disabled)

        model.nameInputModel.text = "Jane"

        #expect(model.buttonState == .normal)
    }
}

// MARK: - Mock

extension ManageContactViewModel {
    static func mock(mode: Mode) -> ManageContactViewModel {
        ManageContactViewModel(
            service: .mock(),
            mode: mode,
            onComplete: nil
        )
    }
}
