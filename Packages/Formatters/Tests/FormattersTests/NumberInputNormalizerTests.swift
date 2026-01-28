// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import BigInt
@testable import Formatters

struct NumberInputNormalizerTests {
    @Test
    func testEnUSNormalization() throws {
        let locale = Locale.US
        let testCases: [(input: String, expected: String)] = [
            ("1,234.56", "1234.56"),
            (" 1,234.56 ", "1234.56"),
            ("1,234.56$", "1234.56"),
            ("1,234.56 USD", "1234.56"),
            ("123,456.78BTC", "123456.78"),
            ("12,345,678,901.23456789", "12345678901.23456789")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testDaDKNormalization() throws {
        let locale = Locale.DA_DK
        let testCases: [(input: String, expected: String)] = [
            ("1.234,56", "1234.56"),
            (" 1.234,56 ", "1234.56"),
            ("1.234,56 kr", "1234.56"),
            ("12.345.678.901,23456789", "12345678901.23456789")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testArabicNormalization() throws {
        let locale = Locale.AR_SA
        let testCases: [(input: String, expected: String)] = [
            ("١٬٢٣٤٫٥٦", "1234.56"),
            (" ١٬٢٣٤٫٥٦ ", "1234.56"),
            ("١٬٢٣٤٫٥٦$", "1234.56"),
            ("١٬٢٣٤٫٥٦ SAR","1234.56"),
            ("١٢٣٬٤٥٦٫٧٨BTC", "123456.78"),
            ("١٢٬٣٤٥٬٦٧٨٬٩٠١٫٢٣٤٥٦٧٨٩", "12345678901.23456789")
        ]

        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testExtraneousSymbols() throws {
        let locale = Locale.US
        let nonBreakingSpace = "\u{00A0}"
        let narrowNoBreakSpace = " "
        let testCases: [(input: String, expected: String)] = [
            ("1,234.56" + nonBreakingSpace + narrowNoBreakSpace, "1234.56"),
            ("1,2 34.5'6", "1234.56"),
            ("123,456.78abc", "123456.78"),
            ("123,456.78BTC", "123456.78")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testCryptoNumbers() throws {
        let locale = Locale.US
        let testCases: [(input: String, expected: String)] = [
            ("12,345.67890 BTC", "12345.67890"),
            ("123,456,789,012,345.67890123", "123456789012345.67890123")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testInputsWithoutGroupingSeparator() throws {
        #expect(NumberInputNormalizer.normalize("1234567.89", locale: Locale.US) == "1234567.89")
        #expect(NumberInputNormalizer.normalize("1234567,89", locale: Locale.DA_DK) == "1234567.89")
    }

    @Test
    func testEmptyOrNonNumericInputs() throws {
        let locale = Locale.US
        let testCases = ["", "   ", "non-digit"]
        for input in testCases {
            #expect(NumberInputNormalizer.normalize(input, locale: locale) == "0")
        }
    }

    @Test
    func testExtremelyLargeNumbers() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.US, "123,456,789,012,345,678.90123456", "123456789012345678.90123456"),
            (Locale.DA_DK, "123.456.789.012.345.678,90123456", "123456789012345678.90123456"),
            (Locale.UK, "987,654,321,098,765,432.10", "987654321098765432.10"),
            (Locale.IT, "1.234.567.890,12345678", "1234567890.12345678"),
            (Locale.PT_BR, "1.234.567.890,12345678", "1234567890.12345678")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testAdditionalVariations() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.FR, "1 234,56 €", "1234.56"),
            (Locale.UA, "1 234,56 грн", "1234.56"),
            (Locale.PT_PT, "1.234,56 €", "1234.56"),
            (Locale.ZH_Simplifier, "1,234.56元", "1234.56"),
            (Locale.ZH_Singapore, "1,234.56SGD", "1234.56"),
            (Locale.ZH_Traditional, "1,234.56HKD", "1234.56")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testInternalSpaceGrouping() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.UA, "1 234,56", "1234.56"),
            (Locale.FR, "1 234,56€", "1234.56")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testTrailingPunctuation() throws {
        let locale = Locale.US
        let input = "123,456.78!!!!"
        let expected = "123456.78"
        let normalized = NumberInputNormalizer.normalize(input, locale: locale)
        #expect(normalized == expected)
    }

    @Test
    func testAlreadyNormalizedInput() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.US, "1234.56", "1234.56"),
            (Locale.DA_DK, "1234.56", "1234.56")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testInputWithoutDecimalSeparator() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.US, "1,234", "1234"),
            (Locale.DA_DK, "1.234", "1234")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testInputWithMixedGrouping() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.US, "1,234 567.89", "1234567.89"),
            (Locale.FR, "1 234 567,89 €", "1234567.89")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testValuesStartingWithZero() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.US, "0.12317", "0.12317"),
            (Locale.US, "00.12317", "0.12317"),
            (Locale.US, "0001234.56", "1234.56"),

            (Locale.FR, "0,12317", "0.12317"),
            (Locale.DA_DK, "0,12317", "0.12317")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }

    @Test
    func testAllLocalesSymbols() throws {
        let testCases: [(locale: Locale, input: String, expected: String)] = [
            (Locale.US, "1,234.56", "1234.56"),
            (Locale.UK, "1,234.56", "1234.56"),
            (Locale.UA, "1 234,56", "1234.56"),
            (Locale.IT, "1.234,56", "1234.56"),
            (Locale.PT_BR, "1.234,56", "1234.56"),
            (Locale.DA_DK, "1.234,56", "1234.56"),
            (Locale.PT_PT, "1.234,56", "1234.56"),
            (Locale.FR, "1 234,56", "1234.56"),
            (Locale.EN_CH, "1'234.56", "1234.56"),
            (Locale.DE_CH, "1'234.56", "1234.56"),
            (Locale.ZH_Simplifier, "1,234.56", "1234.56"),
            (Locale.ZH_Singapore, "1,234.56", "1234.56"),
            (Locale.ZH_Traditional, "1,234.56", "1234.56")
        ]
        for testCase in testCases {
            let normalized = NumberInputNormalizer.normalize(testCase.input, locale: testCase.locale)
            #expect(normalized == testCase.expected)
        }
    }
}
