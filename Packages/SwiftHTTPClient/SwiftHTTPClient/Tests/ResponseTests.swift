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
        _ = try Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:58.101180Z\"}".utf8), headers: [:]).map(as: TestDate.self)
        _ = try Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:58.101180Z\"}".utf8), headers: [:]).map(as: TestDate.self)
        _ = try Response(code: 0, body: Data("{\"date\": \"2025-04-09T17:30:40Z\"}".utf8), headers: [:]).map(as: TestDate.self)
    }

    @Test
    func testMapDateZeroNanoseconds() throws {
        let response = Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:40Z\"}".utf8), headers: [:])
        let expected = TestDate(date: Date(timeIntervalSince1970: 1703627260))
        #expect(try response.map(as: TestDate.self) == expected)
    }
}
