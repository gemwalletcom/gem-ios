// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import DataValidation

struct ContactDescriptionValidatorTests {
    
    @Test
    func testIsValidWithValidInput() async throws {
        let validator = ContactDescriptionValidator()
        let validInput = "This is a valid description under 50 characters."
        
        do {
            let isValid = try validator.isValid(validInput)
            #expect(isValid == true)
        } catch {
            Issue.record("Validation failed for valid input: \(validInput)")
        }
    }
    
    @Test
    func testIsValidWithEmptyInput() async throws {
        let validator = ContactDescriptionValidator()
        let emptyInput = ""
        
        do {
            let isValid = try validator.isValid(emptyInput)
            #expect(isValid == true)
        } catch {
            Issue.record("Validation failed for empty input: \(emptyInput)")
        }
    }
    
    @Test
    func testIsValidWithTooLongInput() async throws {
        let validator = ContactDescriptionValidator()
        let tooLongInput = String(repeating: "A", count: 51)

        do {
            let isValid = try validator.isValid(tooLongInput)
            #expect(isValid == false)
        } catch {
            #expect(true)
        }
    }
    
    @Test
    func testIsValidWithExactLimitInput() async throws {
        let validator = ContactDescriptionValidator()
        let exactLimitInput = String(repeating: "A", count: 50)

        do {
            let isValid = try validator.isValid(exactLimitInput)
            #expect(isValid == true)
        } catch {
            Issue.record("Validation failed for input with exactly 50 characters: \(exactLimitInput)")
        }
    }
}
