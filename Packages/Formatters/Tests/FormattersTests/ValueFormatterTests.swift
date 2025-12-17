// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
import Foundation
import Formatters

final class ValueFormatterTests {
    @Test
    func testShort() {
        let formatter = ValueFormatter(locale: .US, style: .short)

        #expect(formatter.string(123, decimals: 0) == "123.00")
        #expect(formatter.string(12344, decimals: 6) == "0.0123")
        #expect(formatter.string(0, decimals: 0) == "0")

        #expect(formatter.string(1_000_000, decimals: 0) == "1,000,000.00")
        #expect(formatter.string(1_000, decimals: 0) == "1,000.00")
        #expect(formatter.string(100, decimals: 0) == "100.00")
        #expect(formatter.string(10, decimals: 0) == "10.00")
        #expect(formatter.string(1, decimals: 0) == "1.00")

        #expect(formatter.string(1, decimals: 1) == "0.10")
        #expect(formatter.string(1, decimals: 2) == "0.01")
        #expect(formatter.string(1, decimals: 3) == "0.001")

        #expect(formatter.string(1, decimals: 4) == "0.0001")
        #expect(formatter.string(1, decimals: 5) == "0.00")
        #expect(formatter.string(1, decimals: 6) == "0.00")
        #expect(formatter.string(12345678910, decimals: 6) == "12,345.67")

        #expect(formatter.string(7758980129936940, decimals: 18, currency: "BNB") == "0.0077 BNB")
        #expect(formatter.string(2737071, decimals: 8, currency: "BTC") == "0.0273 BTC")
    }

    @Test
    func testMedium() {
        let formatter = ValueFormatter(locale: .US, style: .medium)

        #expect(formatter.string(123, decimals: 0) == "123.00")
        #expect(formatter.string(12344, decimals: 6) == "0.012344")
        #expect(formatter.string(0, decimals: 0) == "0")

        #expect(formatter.string(1_000_000, decimals: 0) == "1,000,000.00")
        #expect(formatter.string(1_000, decimals: 0) == "1,000.00")
        #expect(formatter.string(100, decimals: 0) == "100.00")
        #expect(formatter.string(10, decimals: 0) == "10.00")
        #expect(formatter.string(1, decimals: 0) == "1.00")

        #expect(formatter.string(1, decimals: 1) == "0.10")
        #expect(formatter.string(1, decimals: 2) == "0.01")
        #expect(formatter.string(1, decimals: 3) == "0.001")
        #expect(formatter.string(1, decimals: 4) == "0.0001")
        #expect(formatter.string(1, decimals: 5) == "0.00001")
        #expect(formatter.string(1, decimals: 6) == "0.000001")
        #expect(formatter.string(12345678910, decimals: 6) == "12,345.67891")
        #expect(formatter.string(1, decimals: 7) == "0.0000001")

        #expect(formatter.string(2737071, decimals: 8, currency: "BTC") == "0.02737071 BTC")
    }

    @Test
    func testFull() {
        let formatter = ValueFormatter(locale: .US, style: .full)

        #expect(formatter.string(123, decimals: 0) == "123")
        #expect(formatter.string(12344, decimals: 6) == "0.012344")
        #expect(formatter.string(0, decimals: 0) == "0")

        #expect(formatter.string(1_000_000, decimals: 0) == "1,000,000")
        #expect(formatter.string(1_000, decimals: 0) == "1,000")
        #expect(formatter.string(100, decimals: 0) == "100")
        #expect(formatter.string(10, decimals: 0) == "10")
        #expect(formatter.string(1, decimals: 0) == "1")

        #expect(formatter.string(1, decimals: 1) == "0.1")
        #expect(formatter.string(1, decimals: 2) == "0.01")
        #expect(formatter.string(1, decimals: 3) == "0.001")
        #expect(formatter.string(1, decimals: 4) == "0.0001")
        #expect(formatter.string(1, decimals: 5) == "0.00001")
        #expect(formatter.string(1, decimals: 6) == "0.000001")
        #expect(formatter.string(BigInt("12345678910111213"), decimals: 18) == "0.012345678910111213")
        #expect(formatter.string(BigInt("1"), decimals: 18) == "0.000000000000000001")
        #expect(formatter.string(BigInt("18761627355200464162"), decimals: 18) == "18.761627355200464162")
        #expect(formatter.string(BigInt("4162"), decimals: 18) == "0.000000000000004162")

        #expect(formatter.string(2737071, decimals: 8, currency: "BTC") == "0.02737071 BTC")
    }

    @Test
    func testAmountToDecimal() throws {
        let formatter = ValueFormatter(locale: .US, style: .full)

        #expect(try formatter.number(amount: "123.123") == (try Decimal("123.123", format: .number)))
        #expect(try formatter.number(amount: "0.000000000000004162") == (try Decimal("0.000000000000004162", format: .number)))
        #expect(try formatter.number(amount: "123123495455.393686411234678911") == (try Decimal("123123495455.393686411234678911", format: .number)))
        #expect(try formatter.number(amount: "49.393686411234678911") == (try Decimal("49.393686411234678911", format: .number)))
        #expect(try formatter.number(amount: "49.393686762065998369") == (try Decimal("49.393686762065998369", format: .number)))
    }

    @Test
    func testFromInputUS() throws {
        let formatter = ValueFormatter(locale: .US, style: .full)

        //#expect(try formatter.inputNumber(from: "0,12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "0.12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "122,726.82", decimals: 8) == 12272682000000)
        #expect(try formatter.inputNumber(from: "122 726.82", decimals: 8) == 12272682000000)
        #expect(try formatter.inputNumber(from: "726320.82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726,320.82083", decimals: 5) == 72632082083)
        //expect(try formatter.inputNumber(from: "726'320,82083", decimals: 8))
        #expect(try formatter.inputNumber(from: "0.000000000000004162", decimals: 18) == 4162)
        #expect(try formatter.inputNumber(from: "49.393686762065998369", decimals: 18) == BigInt("49393686762065998369"))
        #expect(try formatter.inputNumber(from: "320,000", decimals: 2) == 32000000)
        #expect(try formatter.inputNumber(from: "320,000.00", decimals: 2) == 32000000)
        #expect(try formatter.inputNumber(from: "100.18054055999998", decimals: 8) == 10018054055)
        //#expect(try formatter.inputNumber(from: "100,18054055999998", decimals: 8) == 10018054055)
    }

    @Test
    func testFromInputRU_UA() throws {
        let formatter = ValueFormatter(locale: .UA, style: .full)

        #expect(try formatter.inputNumber(from: "0,12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "0.12317", decimals: 8) == 12317000)
        //expect(try formatter.inputNumber(from: "122,726.82083", decimals: 8))
        #expect(try formatter.inputNumber(from: "726320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726 320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726'320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "320,000", decimals: 2) == 32000)
        #expect(try formatter.inputNumber(from: "320,000.00", decimals: 2) == 32000)
        #expect(try formatter.inputNumber(from: "100.18054055999998", decimals: 8) == 10018054055)
        #expect(try formatter.inputNumber(from: "100,18054055999998", decimals: 8) == 10018054055)
    }

    @Test
    func testFromInputBR() throws {
        let formatter = ValueFormatter(locale: .PT_BR, style: .full)

        #expect(try formatter.inputNumber(from: "0,12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "0.12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "726320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726 320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726'320,82083", decimals: 8) == 72632082083000)
    }

    @Test
    func testFromInputFR() throws {
        let formatter = ValueFormatter(locale: .FR, style: .full)

        #expect(try formatter.inputNumber(from: "0,12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "0.12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "726320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726 320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726'320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "110'121'212,212", decimals: 8) == 11012121221200000)
    }

    @Test
    func testFromInputDA_DK() throws {
        let formatter = ValueFormatter(locale: .DA_DK, style: .full)

        #expect(try formatter.inputNumber(from: "0,12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "0.12317", decimals: 8) == 12317000)
        #expect(try formatter.inputNumber(from: "726320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726 320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "726'320,82083", decimals: 8) == 72632082083000)
        #expect(try formatter.inputNumber(from: "100,18054055", decimals: 8) == 10018054055)
        #expect(try formatter.inputNumber(from: "100.18054055", decimals: 8) == 10018054055)
    }

    @Test
    func testFromInputEN_CH() throws {
        let formatter = ValueFormatter(locale: .EN_CH, style: .full)

        #expect(try formatter.inputNumber(from: "0.005", decimals: 8) == 500000)
        #expect(try formatter.inputNumber(from: "5.123", decimals: 8) == 512300000)
    }

    @Test
    func testFromInputDE_CH() throws {
        let formatter = ValueFormatter(locale: .DE_CH, style: .full)

        #expect(try formatter.inputNumber(from: "0.005", decimals: 8) == 500000)
        #expect(try formatter.inputNumber(from: "5.123", decimals: 8) == 512300000)
    }

    @Test
    func testFromDouble() throws {
        let formatter = ValueFormatter(locale: .US, style: .full)

        #expect(try formatter.double(from: 122131233, decimals: 0) == Double(122131233.0))
    }

    @Test
    func testAuto() {
        let formatter = ValueFormatter(locale: .US, style: .auto)

        #expect(formatter.string(123, decimals: 0) == "123.00")
        #expect(formatter.string(12344, decimals: 6) == "0.01234")
        #expect(formatter.string(11112344, decimals: 10) == "0.001111")
        #expect(formatter.string(1, decimals: 4) == "0.0001")
        #expect(formatter.string(1, decimals: 5) == "0.00001")
        #expect(formatter.string(4162, decimals: 18) == "0.000000000000004162")
    }
    
    @Test
    func testAbbreviated() {
        let formatter = ValueFormatter(locale: .US, style: .abbreviated)

        #expect(formatter.string(100_000, decimals: 0) == "100K")
        #expect(formatter.string(1_500_000, decimals: 0) == "1.5M")
        #expect(formatter.string(2_300_000_000, decimals: 0) == "2.3B")
        #expect(formatter.string(1_200_000_000_000, decimals: 0) == "1.2T")
        #expect(formatter.string(500_000, decimals: 0, currency: "BTC") == "500K BTC")
        #expect(formatter.string(2_000_000, decimals: 0, currency: "ETH") == "2M ETH")
    }

    @Test
    func testCompact() {
        let formatter = ValueFormatter(locale: .US, style: .compact)

        #expect(formatter.string(1, decimals: 0) == "1")
        #expect(formatter.string(10, decimals: 0) == "10")
        #expect(formatter.string(100, decimals: 0) == "100")
        #expect(formatter.string(1_000, decimals: 0) == "1,000")
        #expect(formatter.string(1_000_000, decimals: 0) == "1,000,000")
        #expect(formatter.string(0, decimals: 0) == "0")

        #expect(formatter.string(15, decimals: 1) == "1.5")
        #expect(formatter.string(123, decimals: 2) == "1.23")
        #expect(formatter.string(1234, decimals: 3) == "1.23")

        #expect(formatter.string(1, decimals: 1) == "0.1")
        #expect(formatter.string(1, decimals: 2) == "0.01")
        #expect(formatter.string(12, decimals: 2) == "0.12")

        #expect(formatter.string(1_000_000, decimals: 6, currency: "USDT") == "1 USDT")
        #expect(formatter.string(1_500_000, decimals: 6, currency: "USDT") == "1.5 USDT")
        #expect(formatter.string(1_230_000, decimals: 6, currency: "USDT") == "1.23 USDT")
    }
}
