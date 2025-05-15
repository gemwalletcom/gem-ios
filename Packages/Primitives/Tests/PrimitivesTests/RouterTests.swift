// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Primitives

@Suite("Router Tests")
struct RouterTests {
    @Test
    func testPushAddsViewToPath() {
        let router = Router<String>()
        router.push(to: "First")
        #expect(router.path.count == 1)
    }

    @Test
    func testPopRemovesLastViewFromPath() {
        let router = Router<String>()
        router.push(to: "First")
        router.push(to: "Second")
        router.pop()
        #expect(router.path.count == 1)
    }

    @Test
    func testPopDoesNothingIfPathIsEmpty() {
        let router = Router<String>()
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test
    func testPopToRootViewRemovesAllElements() {
        let router = Router<String>()
        router.push(to: "First")
        router.push(to: "Second")
        router.popToRootView()
        #expect(router.path.isEmpty)
    }
    
    @Test
    func testMultiplePushesAddsViewsToPath() {
        let router = Router<String>()
        router.push(to: "First")
        router.push(to: "Second")
        router.push(to: "Third")
        #expect(router.path.count == 3)
    }

    @Test
    func testPopAfterSinglePushEmptiesPath() {
        let router = Router<String>()
        router.push(to: "Only")
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test
    func testPresentAlertSetsAlertValue() {
        let router = Router<String>()
        router.presentAlert(title: "Title", message: "Message")
        #expect(router.isPresentingAlert?.title == "Title")
        #expect(router.isPresentingAlert?.message == "Message")
    }

    @Test
    func testOnCompleteIsCalled() {
        var didCall = false
        let router = Router<String>(onFinishFlow: { didCall = true })
        router.onFinishFlow!()
        #expect(didCall)
    }

    @Test
    func testPresentingSetsSheetValue() {
        struct DummyIdentifiable: Identifiable {
            let id = UUID()
        }
        
        let router = Router<String>()
        let view = DummyIdentifiable()
        router.presenting(view)
        
        let presented = router.isPresentingSheet?.value as? DummyIdentifiable
        #expect(presented?.id == view.id)
    }
}
