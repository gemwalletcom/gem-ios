// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit
import Validators

@testable import PrimitivesComponents

private enum DummyError: Error, Equatable { case invalid }
private struct FailableValidator: TextValidator {
    let allowed: String
    var id: String { "failable-\(allowed)" }

    func validate(_ text: String) throws {
        guard text == allowed else { throw DummyError.invalid }
    }
}

@MainActor
struct InputValidationViewModelTests {
    @Test
      func manualModeDoesNotValidateOnTyping() {
          let model = InputValidationViewModel(
              mode: .manual,
              validators: [FailableValidator(allowed: "ok")]
          )

          model.text = "wrong"
          #expect(model.error == nil)
          #expect(model.isValid)
      }

      @Test
      func manualModeValidatesOnExplicitUpdate() {
          let model = InputValidationViewModel(
              mode: .manual,
              validators: [FailableValidator(allowed: "ok")]
          )

          model.text = "wrong"
          let result = model.update()

          #expect(!result)
          #expect(model.error as? DummyError == .invalid)
          #expect(model.isInvalid)
      }

      @Test
      func onDemandModeValidatesOnEachChange() {
          let model = InputValidationViewModel(
              mode: .onDemand,
              validators: [FailableValidator(allowed: "ok")]
          )

          model.text = "wrong"

          #expect(model.error as? DummyError == .invalid)
          #expect(model.isInvalid)
      }

      @Test
      func onDemandModeClearsErrorWhenFixed() {
          let model = InputValidationViewModel(
              mode: .onDemand,
              validators: [FailableValidator(allowed: "ok")]
          )

          model.text = "wrong"
          model.text = "ok"

          #expect(model.error == nil)
          #expect(model.isValid)
      }

      @Test
      func updateValidatorsRevalidatesImmediately() {
          let model = InputValidationViewModel(
              mode: .onDemand,
              validators: [FailableValidator(allowed: "ok")]
          )

          model.text = "wrong"
          #expect(model.isInvalid)

          // update validators
          model.update(validators: [])

          #expect(model.isValid)
          #expect(model.error == nil)
      }

    @Test
    func testUpdateValidatorsWhenTextIsEmpty() {
        let model = InputValidationViewModel(
            mode: .onDemand,
            validators: [FailableValidator(allowed: "ok")]
        )

        model.text = ""
        model.update(error: AnyError("error"))

        model.update(validators: [FailableValidator(allowed: "ok")])

        #expect(model.isValid)
    }
}
