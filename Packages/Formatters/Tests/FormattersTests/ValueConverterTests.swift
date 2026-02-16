// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit

@testable import Formatters

struct ValueConverterTests {
    let converter = ValueConverter()

    @Test
    func testConvertToFiat() throws {
        let price = AssetPrice.mock(price: 2.5)
        #expect(try converter.convertToFiat(amount: "1", price: price) == 2.5)
        #expect(try converter.convertToFiat(amount: "0.4", price: price) == 1.0)
        #expect(try converter.convertToFiat(amount: "10", price: price) == 25.0)
        #expect(try converter.convertToFiat(amount: "0", price: price) == 0.0)
    }

    @Test
    func testConvertToAmount() throws {
        let price = AssetPrice.mock(price: 2.5)
        #expect(try converter.convertToAmount(fiatValue: "2.5", price: price, decimals: 8) == "1.00")
        #expect(try converter.convertToAmount(fiatValue: "1.0", price: price, decimals: 8) == "0.40")
        #expect(try converter.convertToAmount(fiatValue: "25", price: price, decimals: 8) == "10.00")
    }
    
    @Test
    func testConvertToFiatWithZeroAmount() throws {
        #expect(try converter.convertToFiat(amount: "0", price: .mock(price: 2.5)) == 0.0)
    }

    @Test
    func testConvertToAmountWithZeroFiatValue() throws {
        #expect(throws: AnyError.self) {
            try converter.convertToAmount(fiatValue: "0", price: .mock(price: 2.5), decimals: 8) == "0.00"
        }
    }
    
    @Test
    func testConvertToFiatWithSmallAmount() throws {
        #expect(try converter.convertToFiat(amount: "0.00000001", price: .mock(price: 2.5)) == 0.000000025)
    }

    @Test
    func testConvertToAmountWithSmallFiatValue() throws {
        #expect(try converter.convertToAmount(fiatValue: "0.000000025", price: .mock(price: 2.5), decimals: 8) == "0.00000001")
    }
    
    @Test
    func testConvertToAmountWithRounding() throws {
        let price = AssetPrice.mock(price: 3.33333333)
        #expect(try converter.convertToAmount(fiatValue: "10", price: price, decimals: 2) == "3.00")
    }
}

