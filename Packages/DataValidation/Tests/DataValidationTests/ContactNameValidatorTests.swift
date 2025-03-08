// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import DataValidation

struct ContactNameValidatorTests {
    
    @Test
    func testIsValidWithValidInput() {
        let validator = ContactNameValidator()
        let validInput = "John_1234"
        
        do {
            let isValid = try validator.isValid(validInput)
            #expect(isValid)
        } catch {
            Issue.record("Validation failed for valid input: \(validInput)")
        }
    }
    
    @Test
    func testIsValidWithEmptyInput() {
        let validator = ContactNameValidator()
        let emptyInput = ""
        
        do {
            let isValid = try validator.isValid(emptyInput)
            #expect(!isValid)
        } catch {
            #expect(true)
        }
    }
    
    @Test
    func testIsValidWithTooLongInput() {
        let validator = ContactNameValidator()
        let tooLongInput = String(repeating: "A", count: 26)
        
        do {
            let isValid = try validator.isValid(tooLongInput)
            #expect(!isValid)
        } catch {
            #expect(true)
        }
    }
    
    @Test
    func testIsValidWithValidMaxLengthInput() {
        let validator = ContactNameValidator()
        let maxLengthInput = String(repeating: "A", count: 25)
        
        do {
            let isValid = try validator.isValid(maxLengthInput)
            #expect(isValid)
        } catch {
            Issue.record("Validation failed for max length input: \(maxLengthInput)")
        }
    }
}
