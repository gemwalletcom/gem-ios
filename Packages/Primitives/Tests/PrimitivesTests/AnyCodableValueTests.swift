// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import Primitives

struct AnyCodableValueTests {

    @Test
    func decode() throws {
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("null".utf8)) == .null)
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("true".utf8)) == .bool(true))
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("false".utf8)) == .bool(false))
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("42".utf8)) == .int(42))
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("-100".utf8)) == .int(-100))
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("3.14".utf8)) == .double(3.14))
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("\"hello\"".utf8)) == .string("hello"))
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("[1,2]".utf8)) == .array([.int(1), .int(2)]))
        #expect(try JSONDecoder().decode(AnyCodableValue.self, from: Data("{\"key\":\"value\"}".utf8)) == .object(["key": .string("value")]))
    }

    @Test
    func encode() throws {
        #expect(try JSONEncoder().encode(AnyCodableValue.null) == Data("null".utf8))
        #expect(try JSONEncoder().encode(AnyCodableValue.bool(true)) == Data("true".utf8))
        #expect(try JSONEncoder().encode(AnyCodableValue.int(42)) == Data("42".utf8))
        #expect(try JSONEncoder().encode(AnyCodableValue.double(3.5)) == Data("3.5".utf8))
        #expect(try JSONEncoder().encode(AnyCodableValue.string("test")) == Data("\"test\"".utf8))
        #expect(try JSONEncoder().encode(AnyCodableValue.array([.int(1)])) == Data("[1]".utf8))
        #expect(try JSONEncoder().encode(AnyCodableValue.object(["a": .int(1)])) == Data("{\"a\":1}".utf8))
    }

    @Test
    func decodeToType() {
        #expect(AnyCodableValue.string("hello").decode(String.self) == "hello")
        #expect(AnyCodableValue.int(42).decode(Int.self) == 42)
        #expect(AnyCodableValue.string("{\"name\":\"test\"}").decode([String: String].self) == ["name": "test"])
    }

    @Test
    func encodeFromType() {
        #expect(AnyCodableValue.encode("hello") == .string("hello"))
        #expect(AnyCodableValue.encode(42) == .int(42))
        #expect(AnyCodableValue.encode(true) == .bool(true))
    }
}
