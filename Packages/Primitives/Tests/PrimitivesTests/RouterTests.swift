// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Primitives

@Suite("Router Tests")
@MainActor
struct RouterTests {
    @Test
    func testPushAddsViewToStack() {
        let router = Router<String>()
        router.push(to: "First")
        #expect(router.stack == ["First"])
    }

    @Test
    func testPopRemovesLastViewFromStack() {
        let router = Router<String>()
        router.push(to: "First")
        router.push(to: "Second")
        router.pop()
        #expect(router.stack == ["First"])
    }

    @Test
    func testPopDoesNothingIfStackIsEmpty() {
        let router = Router<String>()
        router.pop()
        #expect(router.stack == [])
    }

    @Test
    func testNavigateBackToExistingView() {
        let router = Router<String>()
        router.push(to: "First")
        router.push(to: "Second")
        router.push(to: "Third")
        router.navigateBack(to: "Second")
        #expect(router.stack == ["First", "Second"])
    }

    @Test
    func testNavigateBackToNonexistentView() {
        let router = Router<String>()
        router.push(to: "First")
        router.push(to: "Second")
        router.navigateBack(to: "Unknown")
        #expect(router.stack == ["First", "Second"])
    }
}
