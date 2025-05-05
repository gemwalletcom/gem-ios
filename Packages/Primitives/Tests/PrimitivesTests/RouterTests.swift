// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Primitives

@Suite("Router Tests")
struct RouterTests {
    @Test
    func testPushAddsViewToPath() {
        let router = Router(onComplete: {})
        router.push(to: "First")
        #expect(router.path.count == 1)
    }

    @Test
    func testPopRemovesLastViewFromPath() {
        let router = Router(onComplete: {})
        router.push(to: "First")
        router.push(to: "Second")
        router.pop()
        #expect(router.path.count == 1)
    }

    @Test
    func testPopDoesNothingIfPathIsEmpty() {
        let router = Router(onComplete: {})
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test
    func testPopToRootViewRemovesAllElements() {
        let router = Router(onComplete: {})
        router.push(to: "First")
        router.push(to: "Second")
        router.popToRootView()
        #expect(router.path.isEmpty)
    }
    
    @Test
    func testMultiplePushesAddsViewsToPath() {
        let router = Router(onComplete: {})
        router.push(to: "First")
        router.push(to: "Second")
        router.push(to: "Third")
        #expect(router.path.count == 3)
    }

    @Test
    func testPopAfterSinglePushEmptiesPath() {
        let router = Router(onComplete: {})
        router.push(to: "Only")
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test
    func testPresentAlertSetsAlertValue() {
        let router = Router(onComplete: {})
        router.presentAlert(title: "Title", message: "Message")
        #expect(router.isPresentingAlert?.title == "Title")
        #expect(router.isPresentingAlert?.message == "Message")
    }

    @Test
    func testOnCompleteIsCalled() {
        var didCall = false
        let router = Router(onComplete: { didCall = true })
        router.onComplete!()
        #expect(didCall)
    }
}
