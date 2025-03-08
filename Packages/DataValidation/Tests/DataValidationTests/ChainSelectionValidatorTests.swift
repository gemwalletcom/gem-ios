// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import DataValidation

struct ChainSelectionValidatorTests {
    
    @Test
    func testIsValidWithSelectedChain() {
        let validator = ChainSelectionValidator()
        let selectedChain: Chain? = .bitcoin
        
        do {
            let isValid = try validator.isValid(selectedChain)
            #expect(isValid)
        } catch {
            Issue.record("Validation failed for selected chain")
        }
    }
    
    @Test
    func testIsValidWithNoSelectedChain() {
        let validator = ChainSelectionValidator()
        let selectedChain: Chain? = nil
        
        do {
            let isValid = try validator.isValid(selectedChain)
            #expect(!isValid)
        } catch {
            #expect(true)
        }
    }
}
