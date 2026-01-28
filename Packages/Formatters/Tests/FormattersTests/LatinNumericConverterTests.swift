// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import Formatters

struct LatinNumericConverterTests {
    @Test
    func testArabicIndicDigits() throws {
        #expect(LatinNumericConverter.toLatinDigits("٤٥٦") == "456")
    }

    @Test
    func testExtendedArabicDigits() throws {
        #expect(LatinNumericConverter.toLatinDigits("۹۸۷") == "987")
    }

    @Test
    func testArabicDecimalSeparator() throws {
        #expect(LatinNumericConverter.toLatinDigits("١٢٣٫٤٥") == "123.45")
    }

    @Test
    func testArabicThousandsSeparator() throws {
        #expect(LatinNumericConverter.toLatinDigits("١٢٬٣٤٥") == "12345")
    }

    @Test
    func testArabicFullExample() throws {
        let input = "١٢٬٣٤٥٬٦٧٨٫٩٠١٢٣"
        let expected = "12345678.90123"
        #expect(LatinNumericConverter.toLatinDigits(input) == expected)
    }

    @Test
    func testArabicDigitsWithSuffix() throws {
        #expect(LatinNumericConverter.toLatinDigits("٤٥٦BTC") == "456BTC")
    }

    @Test
    func testLatinDigitsWithArabicDecimal() throws {
        #expect(LatinNumericConverter.toLatinDigits("123٫45") == "123.45")
    }

    @Test
    func testEmptyString() throws {
        #expect(LatinNumericConverter.toLatinDigits("") == "")
    }
}
