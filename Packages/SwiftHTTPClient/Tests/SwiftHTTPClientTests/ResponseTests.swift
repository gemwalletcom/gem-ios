// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import SwiftHTTPClient

struct TestDate: Codable, Equatable {
    let date: Date
}

struct ResponseTests {
    
    let encoder = JSONEncoder()

    @Test
    func testMapInt() throws {
        let response = Response(code: 0, body: Data("1".utf8), headers: [:])
        #expect(try response.map(as: Int.self) == 1)
    }

    @Test
    func testMapArray() throws {
        let response = Response(code: 0, body: Data("[]".utf8), headers: [:])
        #expect(try response.map(as: [String].self) == [])
    }

    @Test
    func testMapDate() throws {
        let response = Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:58.101180Z\"}".utf8), headers: [:])
        _ = try response.map(as: TestDate.self)
    }

    @Test
    func testMapDateZeroNanoseconds() throws {
        let response = Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:40Z\"}".utf8), headers: [:])
        let expected = TestDate(date: Date(timeIntervalSince1970: 1703627260))
        #expect(try response.map(as: TestDate.self) == expected)
    }

    @Test
    func testMapDateRoundToMilliseconds() throws {
        let response = Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:58.101180Z\"}".utf8), headers: [:])
        let date = try response.map(as: TestDate.self)

        #expect(date.date.description == "2023-12-26 9:47:58 PM +0000")
        #expect(date.date.timeIntervalSinceReferenceDate == 725320078.1010001)
    }
}
