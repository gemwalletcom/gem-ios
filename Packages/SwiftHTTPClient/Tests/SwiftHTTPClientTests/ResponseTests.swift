// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import SwiftHTTPClient

struct TestDate: Codable, Equatable {
    let date: Date
}

final class ResponseTests: XCTestCase {

    let encoder = JSONEncoder()
    
    func testMapInt() {
        let response = Response(code: 0, body: Data("1".utf8), headers: [:])
        XCTAssertEqual(try response.map(as: Int.self), 1)
    }
    
    func testMapArray() {
        let response = Response(code: 0, body: Data("[]".utf8), headers: [:])
        XCTAssertEqual(try response.map(as: [String].self), [])
    }
    
    func testMapDate() {
        let response = Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:58.101180Z\"}".utf8), headers: [:])
        XCTAssertNotNil(try response.map(as: TestDate.self))
    }
    
    func testMapDateZeroNanoseconds() {
        let response = Response(code: 0, body: Data("{\"date\": \"2023-12-26T21:47:40Z\"}".utf8), headers: [:])
        XCTAssertEqual(try response.map(as: TestDate.self), TestDate(date: Date(timeIntervalSince1970: 1703627260)))
    }
}
