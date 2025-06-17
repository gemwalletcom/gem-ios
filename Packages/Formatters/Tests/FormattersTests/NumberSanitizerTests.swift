// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Formatters

struct NumberSanitizerTests {
    
    @Test
    func testSanitize_validNumber_shouldRemainUnchanged() throws {
        let sanitizer = NumberSanitizer(decimalSeparator: ".")
        #expect(sanitizer.sanitize("123.45") == "123.45")
    }

    @Test
    func testSanitize_multipleDecimalSeparators_shouldKeepFirstOnly() throws {
        let sanitizer = NumberSanitizer(decimalSeparator: ".")
        #expect(sanitizer.sanitize("123.45.67") == "123.4567")
    }

    @Test
    func testSanitize_nonNumericCharacters_shouldRemoveThem() throws {
        let sanitizer = NumberSanitizer(decimalSeparator: ".")
        #expect(sanitizer.sanitize("abc123.45xyz") == "123.45")
    }

    @Test
    func testSanitize_whitespace_shouldBeRemoved() throws {
        let sanitizer = NumberSanitizer(decimalSeparator: ".")
        #expect(sanitizer.sanitize("  1 23 . 4 5 ") == "123.45")
    }

    @Test
    func testSanitize_symbols_shouldBeRemoved() throws {
        let sanitizer = NumberSanitizer(decimalSeparator: ".")
        #expect(sanitizer.sanitize("$123.45€") == "123.45")
    }

    @Test
    func testSanitize_differentDecimalSeparator_shouldBeUsed() throws {
        let sanitizer = NumberSanitizer(decimalSeparator: ",")
        #expect(sanitizer.sanitize("123,45,67") == "123,4567")
    }

    @Test
    func testSanitize_emptyString_shouldReturnEmptyString() throws {
        let sanitizer = NumberSanitizer(decimalSeparator: ".")
        #expect(sanitizer.sanitize("") == "")
    }
}
