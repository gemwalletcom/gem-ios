// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import StoreTestKit
import ContactService
import Components
import NameServiceTestKit

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
    static func mock(
        nameService: any NameServiceable = .mock(),
        mode: Mode
    ) -> ManageContactViewModel {
        ManageContactViewModel(
            service: ContactService(store: .mock(), addressStore: .mock()),
            nameService: nameService,
            mode: mode,
            onComplete: nil
        )
    }
}
