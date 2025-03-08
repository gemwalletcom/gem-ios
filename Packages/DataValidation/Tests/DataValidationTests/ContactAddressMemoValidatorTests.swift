// Copyright (c). Gem Wallet. All rights reserved.
import Testing
@testable import DataValidation

struct ContactAddressMemoValidatorTests {
    
    @Test
    func testIsValidWithValidInput() {
        let validator = ContactAddressMemoValidator()
        let validInput = "This is a valid description under 150 characters."
        
        do {
            let isValid = try validator.isValid(validInput)
            #expect(isValid)
        } catch {
            Issue.record("Validation failed for valid input: \(validInput)")
        }
    }
    
    @Test
    func testIsValidWithEmptyInput() {
        let validator = ContactAddressMemoValidator()
        let emptyInput = ""
        
        do {
            let isValid = try validator.isValid(emptyInput)
            #expect(isValid)
        } catch {
            Issue.record("Validation failed for empty input: \(emptyInput)")
        }
    }
    
    @Test
    func testIsValidWithTooLongInput() {
        let validator = ContactAddressMemoValidator()
        let tooLongInput = String(repeating: "A", count: 151)
        
        do {
            let isValid = try validator.isValid(tooLongInput)
            #expect(!isValid)
        } catch {
            #expect(true)
        }
    }
    
    @Test
    func testIsValidWithExactLimitInput() {
        let validator = ContactAddressMemoValidator()
        let exactLimitInput = String(repeating: "A", count: 150)
        
        do {
            let isValid = try validator.isValid(exactLimitInput)
            #expect(isValid)
        } catch {
            Issue.record("Validation failed for input with exact 150 characters: \(exactLimitInput)")
        }
    }
    
}
