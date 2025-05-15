// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit

@testable import PrimitivesComponents

private enum DummyError: LocalizedError {
    case boom
}

private struct StubValidator: TextValidator {
    let shouldPass: Bool

    func validate(_ text: String) throws {
        if !shouldPass {
            throw DummyError.boom
        }
    }

    var id: String { "StubValidator" }
}

private struct NonEmptyValidator: TextValidator {
    func validate(_ text: String) throws {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw AnyError("not-empty")
        }
    }

    var id: String { "NonEmptyValidator" }
}

private struct LengthLimitValidator: TextValidator {
    let max: Int
    func validate(_ text: String) throws {
        if text.count > max {
            throw AnyError("too long")
        }
    }

    var id: String { "LengthLimitValidator" }
}

@MainActor
struct InputValidationViewModelTests {
    @Test
    func combinedValidatorsAllPass() {
        let viewModel = InputValidationViewModel(
            validators: [
                NonEmptyValidator(),
                LengthLimitValidator(max: 10),
                StubValidator(shouldPass: true)
            ]
        )

        #expect(viewModel.update(text: "Gem"))
        #expect(viewModel.error == nil)
    }

    @Test
    func combinedValidatorsFailWhenOneRuleFails() {
        let vm = InputValidationViewModel(
            validators: [
                NonEmptyValidator(),
                LengthLimitValidator(max: 3),   // will fail
                StubValidator(shouldPass: true)
            ]
        )

        #expect(!vm.update(text: "GemWallet"))
        #expect(vm.error != nil)
        #expect(!vm.isValid)
    }

    @Test
    func combinedValidatorsFailWhenStubFails() {
        let vm = InputValidationViewModel(
            validators: [
                NonEmptyValidator(),
                LengthLimitValidator(max: 10),
                StubValidator(shouldPass: false)   // fail toggle
            ]
        )

        #expect(!vm.update(text: "Gem"))
        #expect(vm.error is DummyError)
    }

    @Test
    func manualValidationPassesWhenAllRulesPass() {
        let viewModel = InputValidationViewModel(
            mode: .manual,
            validators: [StubValidator(shouldPass: true)]
        )

        viewModel.text = "hello"

        #expect(viewModel.validate())
        #expect(viewModel.error == nil)
        #expect(viewModel.isValid)
    }

    @Test
    func manualValidationFailsWhenAnyRuleFails() {
        let viewModel = InputValidationViewModel(
            mode: .manual,
            validators: [StubValidator(shouldPass: false)]
        )
        viewModel.text = "hello"

        #expect(!viewModel.validate())
        #expect(viewModel.error is DummyError)
        #expect(!viewModel.isValid)
    }

    @Test
    func liveValidationRunsAutomatically() {
        let viewModel = InputValidationViewModel(
            mode: .live,
            validators: [StubValidator(shouldPass: false)]
        )
        viewModel.text = "change triggers didSet"

        #expect(viewModel.error is DummyError)
        #expect(!viewModel.isValid)
    }

    @Test
    func updateTextValidatesAndReturnsBool() {
        let viewModel = InputValidationViewModel(
            validators: [StubValidator(shouldPass: true)]
        )

        #expect(viewModel.update(text: "abc"))
        #expect(viewModel.error == nil)
    }

    @Test
    func updateValidatorsRevalidatesImmediately() {
        let viewModel = InputValidationViewModel(
            validators: [StubValidator(shouldPass: true)]
        )
        viewModel.text = "abc"
        _ = viewModel.validate()

        // inject a failing rule
        viewModel.updateValidators([StubValidator(shouldPass: false)])

        #expect(viewModel.error is DummyError)
        #expect(!viewModel.isValid)
    }

    @Test
    func updateCustomErrorOverridesAndClears() {
        let viewModel = InputValidationViewModel(validators: [])

        viewModel.update(customError: DummyError.boom)
        #expect(viewModel.error is DummyError)

        viewModel.update(customError: nil)
        #expect(viewModel.error == nil)
    }
}
