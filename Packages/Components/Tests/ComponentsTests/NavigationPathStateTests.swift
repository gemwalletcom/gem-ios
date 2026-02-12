// Copyright (c). Gem Wallet. All rights reserved.

import Testing

@testable import Components

@MainActor
struct NavigationPathStateTests {

    @Test
    func initialState() {
        let state = NavigationPathState()

        #expect(state.isEmpty == true)
        #expect(state.count == 0)
    }

    @Test
    func appendElement() {
        let state = NavigationPathState()

        #expect(state.append(TestScene(id: "a")) == true)
        #expect(state.count == 1)
    }

    @Test
    func appendDuplicateElement() {
        let state = NavigationPathState()
        state.append(TestScene(id: "a"))

        #expect(state.append(TestScene(id: "a")) == false)
        #expect(state.count == 1)
    }

    @Test
    func appendDifferentElement() {
        let state = NavigationPathState()
        state.append(TestScene(id: "a"))

        #expect(state.append(TestScene(id: "b")) == true)
        #expect(state.count == 2)
    }

    @Test
    func appendDifferentType() {
        let state = NavigationPathState()
        state.append(TestScene(id: "a"))

        #expect(state.append(OtherScene(id: "a")) == true)
        #expect(state.count == 2)
    }

    @Test
    func setPath() {
        let state = NavigationPathState()

        state.setPath([TestScene(id: "a"), TestScene(id: "b"), TestScene(id: "c")])

        #expect(state.count == 3)
    }

    @Test
    func setPathOverwrites() {
        let state = NavigationPathState()
        state.append(TestScene(id: "x"))

        state.setPath([TestScene(id: "a"), TestScene(id: "b")])

        #expect(state.count == 2)
    }

    @Test
    func reset() {
        let state = NavigationPathState()
        state.append(TestScene(id: "a"))

        state.reset()

        #expect(state.isEmpty == true)
    }

    @Test
    func removeLast() {
        let state = NavigationPathState()
        state.append(TestScene(id: "a"))
        state.append(TestScene(id: "b"))

        state.removeLast()

        #expect(state.count == 1)
    }
}

private struct TestScene: Hashable, Codable {
    let id: String
}

private struct OtherScene: Hashable, Codable {
    let id: String
}
