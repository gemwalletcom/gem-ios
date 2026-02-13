// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Primitives

struct URLTests {

    @Test
    func testCleanHost() {
        #expect(URL(string: "https://www.example.com")?.cleanHost() == "example.com")
        #expect(URL(string: "https://www.example.com/about-us")?.cleanHost() == "example.com")
    }

    @Test
    func toWebSocketURL() {
        #expect(URL(string: "https://node.example.com/hypercore")?.toWebSocketURL().absoluteString == "wss://node.example.com/hypercore")
        #expect(URL(string: "http://localhost:8080/hypercore")?.toWebSocketURL().absoluteString == "ws://localhost:8080/hypercore")
        #expect(URL(string: "wss://node.example.com/hypercore/ws")?.toWebSocketURL().absoluteString == "wss://node.example.com/hypercore/ws")
    }
}
