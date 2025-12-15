// Copyright (c). Gem Wallet. All rights reserved.

import Testing

@testable import Perpetuals
@testable import PerpetualsTestKit

struct AutocloseFieldTests {

    @Test
    func hasChanged() {
        #expect(AutocloseField.mock(price: 100.0, originalPrice: 100.0).hasChanged == false)
        #expect(AutocloseField.mock(price: 100.0, originalPrice: 90.0).hasChanged == true)
        #expect(AutocloseField.mock(price: nil, originalPrice: 100.0).hasChanged == true)
        #expect(AutocloseField.mock(price: nil, originalPrice: nil).hasChanged == false)
    }

    @Test
    func isCleared() {
        #expect(AutocloseField.mock(price: nil, originalPrice: 100.0).isCleared == true)
        #expect(AutocloseField.mock(price: 100.0, originalPrice: 100.0).isCleared == false)
        #expect(AutocloseField.mock(price: nil, originalPrice: nil).isCleared == false)
    }

    @Test
    func hasExisting() {
        #expect(AutocloseField.mock(originalPrice: 100.0).hasExisting == true)
        #expect(AutocloseField.mock(originalPrice: nil).hasExisting == false)
    }

    @Test
    func shouldSet() {
        #expect(AutocloseField.mock(price: 110.0, originalPrice: 100.0, isValid: true).shouldSet == true)
        #expect(AutocloseField.mock(price: 100.0, originalPrice: 100.0, isValid: true).shouldSet == false)
        #expect(AutocloseField.mock(price: 110.0, originalPrice: 100.0, isValid: false).shouldSet == false)
        #expect(AutocloseField.mock(price: nil, originalPrice: 100.0, isValid: false).shouldSet == false)
    }

    @Test
    func shouldUpdate() {
        #expect(AutocloseField.mock(price: 110.0, originalPrice: 100.0, isValid: true).shouldUpdate == true)
        #expect(AutocloseField.mock(price: nil, originalPrice: 100.0, isValid: true).shouldUpdate == true)
        #expect(AutocloseField.mock(price: 100.0, originalPrice: 100.0, isValid: true).shouldUpdate == false)
    }

    @Test
    func shouldCancel() {
        #expect(AutocloseField.mock(price: nil, originalPrice: 100.0, isValid: true).shouldCancel == true)
        #expect(AutocloseField.mock(price: 110.0, originalPrice: 100.0, isValid: true).shouldCancel == true)
        #expect(AutocloseField.mock(price: 110.0, originalPrice: nil, isValid: true).shouldCancel == false)
        #expect(AutocloseField.mock(price: 100.0, originalPrice: 100.0, isValid: true).shouldCancel == false)
    }

    @Test
    func newOrderNoExisting() {
        let field = AutocloseField.mock(price: 100.0, originalPrice: nil, isValid: true)
        #expect(field.shouldSet == true)
        #expect(field.shouldCancel == false)
        #expect(field.shouldUpdate == true)
    }

    @Test
    func updateExistingOrder() {
        let field = AutocloseField.mock(price: 110.0, originalPrice: 100.0, isValid: true)
        #expect(field.shouldSet == true)
        #expect(field.shouldCancel == true)
        #expect(field.shouldUpdate == true)
    }

    @Test
    func clearExistingOrder() {
        let field = AutocloseField.mock(price: nil, originalPrice: 100.0, isValid: false)
        #expect(field.shouldSet == false)
        #expect(field.shouldCancel == true)
        #expect(field.shouldUpdate == true)
        #expect(field.isCleared == true)
    }

    @Test
    func noChanges() {
        let field = AutocloseField.mock(price: 100.0, originalPrice: 100.0, isValid: true)
        #expect(field.shouldSet == false)
        #expect(field.shouldCancel == false)
        #expect(field.shouldUpdate == false)
        #expect(field.hasChanged == false)
    }
}
