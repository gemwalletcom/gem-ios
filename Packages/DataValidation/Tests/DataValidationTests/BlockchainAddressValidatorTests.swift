// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import DataValidation

struct BlockchainAddressValidatorTests {
    
    @Test
    func testIsValidWithValidAddress() {
        let validator = BlockchainAddressValidator(chain: .bitcoin)
        let validAddress = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
        
        do {
            let isValid = try validator.isValid(validAddress)
            #expect(isValid)
        } catch {
            Issue.record("Validation failed for valid address: \(validAddress)")
        }
    }
    
    @Test
    func testIsValidWithInvalidAddress() {
        let validator = BlockchainAddressValidator(chain: .bitcoin)
        let invalidAddress = "InvalidAddress123"
        
        do {
            let isValid = try validator.isValid(invalidAddress)
            #expect(!isValid)
        } catch {
            #expect(true)
        }
    }
    
    @Test
    func testIsValidWithNilChain() {
        let validator = BlockchainAddressValidator(chain: nil)
        let address = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
        
        do {
            let isValid = try validator.isValid(address)
            #expect(!isValid)
        } catch {
            #expect(true)
        }
    }
}
