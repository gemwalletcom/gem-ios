// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives
import BigInt

final class ValueFormatterTests: XCTestCase {

    func testShort() {
        let formatter = ValueFormatter(locale: .US, style: .short)
        
        XCTAssertEqual(formatter.string(123, decimals: 0), "123.00")
        XCTAssertEqual(formatter.string(12344, decimals: 6), "0.0123")
        XCTAssertEqual(formatter.string(0, decimals: 0), "0")
        
        XCTAssertEqual(formatter.string(1_000_000, decimals: 0), "1,000,000.00")
        XCTAssertEqual(formatter.string(1_000, decimals: 0), "1,000.00")
        XCTAssertEqual(formatter.string(100, decimals: 0), "100.00")
        XCTAssertEqual(formatter.string(10, decimals: 0), "10.00")
        XCTAssertEqual(formatter.string(1, decimals: 0), "1.00")
        
        XCTAssertEqual(formatter.string(1, decimals: 1), "0.10")
        XCTAssertEqual(formatter.string(1, decimals: 2), "0.01")
        XCTAssertEqual(formatter.string(1, decimals: 3), "0.001")
        
        XCTAssertEqual(formatter.string(1, decimals: 4), "0.0001")
        XCTAssertEqual(formatter.string(1, decimals: 5), "0.00")
        XCTAssertEqual(formatter.string(1, decimals: 6), "0.00")
        XCTAssertEqual(formatter.string(12345678910, decimals: 6), "12,345.67")
        
        XCTAssertEqual(formatter.string(7758980129936940, decimals: 18, currency: "BNB"), "0.0077 BNB")
        XCTAssertEqual(formatter.string(2737071, decimals: 8, currency: "BTC"), "0.0273 BTC")
    }
    
    func testMedium() {
        let formatter = ValueFormatter(locale: .US, style: .medium)
        
        XCTAssertEqual(formatter.string(123, decimals: 0), "123.00")
        XCTAssertEqual(formatter.string(12344, decimals: 6), "0.012344")
        XCTAssertEqual(formatter.string(0, decimals: 0), "0")
        
        XCTAssertEqual(formatter.string(1_000_000, decimals: 0), "1,000,000.00")
        XCTAssertEqual(formatter.string(1_000, decimals: 0), "1,000.00")
        XCTAssertEqual(formatter.string(100, decimals: 0), "100.00")
        XCTAssertEqual(formatter.string(10, decimals: 0), "10.00")
        XCTAssertEqual(formatter.string(1, decimals: 0), "1.00")
        
        XCTAssertEqual(formatter.string(1, decimals: 1), "0.10")
        XCTAssertEqual(formatter.string(1, decimals: 2), "0.01")
        XCTAssertEqual(formatter.string(1, decimals: 3), "0.001")
        XCTAssertEqual(formatter.string(1, decimals: 4), "0.0001")
        XCTAssertEqual(formatter.string(1, decimals: 5), "0.00001")
        XCTAssertEqual(formatter.string(1, decimals: 6), "0.000001")
        XCTAssertEqual(formatter.string(12345678910, decimals: 6), "12,345.67891")
        XCTAssertEqual(formatter.string(1, decimals: 7), "0.0000001")
        
        XCTAssertEqual(formatter.string(2737071, decimals: 8, currency: "BTC"), "0.02737071 BTC")
    }
    
    func testFull() {
        let formatter = ValueFormatter(locale: .US, style: .full)
        
        XCTAssertEqual(formatter.string(123, decimals: 0), "123")
        XCTAssertEqual(formatter.string(12344, decimals: 6), "0.012344")
        XCTAssertEqual(formatter.string(0, decimals: 0), "0")
        
        XCTAssertEqual(formatter.string(1_000_000, decimals: 0), "1,000,000")
        XCTAssertEqual(formatter.string(1_000, decimals: 0), "1,000")
        XCTAssertEqual(formatter.string(100, decimals: 0), "100")
        XCTAssertEqual(formatter.string(10, decimals: 0), "10")
        XCTAssertEqual(formatter.string(1, decimals: 0), "1")
        
        XCTAssertEqual(formatter.string(1, decimals: 1), "0.1")
        XCTAssertEqual(formatter.string(1, decimals: 2), "0.01")
        XCTAssertEqual(formatter.string(1, decimals: 3), "0.001")
        XCTAssertEqual(formatter.string(1, decimals: 4), "0.0001")
        XCTAssertEqual(formatter.string(1, decimals: 5), "0.00001")
        XCTAssertEqual(formatter.string(1, decimals: 6), "0.000001")
        XCTAssertEqual(formatter.string(12345678910111213, decimals: 18), "0.012345678910111213")
        XCTAssertEqual(formatter.string(1, decimals: 18), "0.000000000000000001")
        XCTAssertEqual(formatter.string(BigInt("18761627355200464162"), decimals: 18), "18.761627355200464162")
        XCTAssertEqual(formatter.string(BigInt("4162"), decimals: 18), "0.000000000000004162")
        
        XCTAssertEqual(formatter.string(2737071, decimals: 8, currency: "BTC"), "0.02737071 BTC")
    }
    
    func testAmountToDecimal() {
        let formatter = ValueFormatter(locale: .US, style: .full)
        
        XCTAssertEqual(try formatter.number(amount: "123.123"), try Decimal("123.123", format: .number))
        XCTAssertEqual(try formatter.number(amount: "0.000000000000004162"), try Decimal("0.000000000000004162", format: .number))
        //XCTAssertEqual(try formatter.number(amount: "123123495455.393686411234678911"), try Decimal("123123495455.393686411234678911", format: .number))
        XCTAssertEqual(try formatter.number(amount: "49.393686411234678911"), try Decimal("49.393686411234678911", format: .number))
        XCTAssertEqual(try formatter.number(amount: "49.393686762065998369"), try Decimal("49.393686762065998369", format: .number))
    }
    
    func testFromInputUS() {
        let formatter = ValueFormatter(locale: .US, style: .full)
        
        //XCTAssertEqual(try formatter.inputNumber(from: "0,12317", decimals: 8), 12317000)
        XCTAssertEqual(try formatter.inputNumber(from: "0.12317", decimals: 8), 12317000)
        //XCTAssertEqual(try formatter.inputNumber(from: "122,726.82", decimals: 8), 12272682000000)
        XCTAssertEqual(try formatter.inputNumber(from: "122 726.82", decimals: 8), 12272682000000)
        XCTAssertEqual(try formatter.inputNumber(from: "726320.82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "726,320.82083", decimals: 5), 72632082083)
        //XCTAssertThrowsError(try formatter.inputNumber(from: "726'320,82083", decimals: 8))
        XCTAssertEqual(try formatter.inputNumber(from: "0.000000000000004162", decimals: 18), 4162)
        XCTAssertEqual(try formatter.inputNumber(from: "49.393686762065998369", decimals: 18), BigInt("49393686762065998369"))
        XCTAssertEqual(try formatter.inputNumber(from: "320,000", decimals: 2), 32000000)
        XCTAssertEqual(try formatter.inputNumber(from: "320,000.00", decimals: 2), 32000000)
    }
    
    func testFromInputRU_UA() {
        let formatter = ValueFormatter(locale: .UA, style: .full)
        
        XCTAssertEqual(try formatter.inputNumber(from: "0,12317", decimals: 8), 12317000)
        XCTAssertEqual(try formatter.inputNumber(from: "0.12317", decimals: 8), 12317000)
        //XCTAssertThrowsError(try formatter.inputNumber(from: "122,726.82083", decimals: 8))
        XCTAssertEqual(try formatter.inputNumber(from: "726320,82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "726 320,82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "726'320,82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "320,000", decimals: 2), 32000)
        XCTAssertEqual(try formatter.inputNumber(from: "320,000.00", decimals: 2), 32000)
    }
    
    func testFromInputBR() {
        let formatter = ValueFormatter(locale: .BR, style: .full)
        
        XCTAssertEqual(try formatter.inputNumber(from: "0,12317", decimals: 8), 12317000)
        XCTAssertEqual(try formatter.inputNumber(from: "0.12317", decimals: 8), 12317000)
        XCTAssertEqual(try formatter.inputNumber(from: "726320,82083", decimals: 8), 72632082083000)
        //XCTAssertEqual(try formatter.inputNumber(from: "726 320,82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "726'320,82083", decimals: 8), 72632082083000)
    }
    
    func testFromInputFR() {
        let formatter = ValueFormatter(locale: .FR, style: .full)
        
        XCTAssertEqual(try formatter.inputNumber(from: "0,12317", decimals: 8), 12317000)
        XCTAssertEqual(try formatter.inputNumber(from: "0.12317", decimals: 8), 12317000)
        XCTAssertEqual(try formatter.inputNumber(from: "726320,82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "726 320,82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "726'320,82083", decimals: 8), 72632082083000)
        XCTAssertEqual(try formatter.inputNumber(from: "110'121'212,212", decimals: 8), 11012121221200000)
    }
    
    func testFromInputEN_CH() {
        let formatter = ValueFormatter(locale: .EN_CH, style: .full)
        
        XCTAssertEqual(try formatter.inputNumber(from: "0.005", decimals: 8), 500000)
        XCTAssertEqual(try formatter.inputNumber(from: "5.123", decimals: 8), 512300000)
    }
    
    func testFromInputDE_CH() {
        let formatter = ValueFormatter(locale: .DE_CH, style: .full)
        
        XCTAssertEqual(try formatter.inputNumber(from: "0.005", decimals: 8), 500000)
        XCTAssertEqual(try formatter.inputNumber(from: "5.123", decimals: 8), 512300000)
    }
    
    func testFromDouble() {
        let formatter = ValueFormatter(locale: .US, style: .full)
        
        XCTAssertEqual(try formatter.double(from: 122131233, decimals: 0), Double(122131233.0))
    }
}
