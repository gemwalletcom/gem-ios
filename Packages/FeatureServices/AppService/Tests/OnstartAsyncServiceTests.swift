// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import AppServiceTestKit
import Primitives

@testable import AppService

struct OnstartAsyncServiceTests {

    @Test
    func runEmpty() async {
        let service = OnstartAsyncService.mock()
        await service.run()
    }

    @Test
    func runExecutesAllRunners() async {
        let runner1 = TrackingRunner(id: "runner1")
        let runner2 = TrackingRunner(id: "runner2")
        let runner3 = TrackingRunner(id: "runner3")
        let service = OnstartAsyncService.mock(runners: [runner1, runner2, runner3])

        await service.run()

        #expect(runner1.didRun)
        #expect(runner2.didRun)
        #expect(runner3.didRun)
    }

    @Test
    func failingRunnerDoesNotStopOthers() async {
        let runner1 = TrackingRunner(id: "runner1")
        let failingRunner = FailingRunner(id: "failing")
        let runner2 = TrackingRunner(id: "runner2")
        let service = OnstartAsyncService.mock(runners: [runner1, failingRunner, runner2])

        await service.run()

        #expect(runner1.didRun)
        #expect(runner2.didRun)
    }
}

// MARK: - Test Helpers

private final class TrackingRunner: AsyncRunnable, @unchecked Sendable {
    let id: String
    private(set) var didRun = false

    init(id: String) {
        self.id = id
    }

    func run() async throws {
        didRun = true
    }
}

private struct FailingRunner: AsyncRunnable {
    let id: String

    func run() async throws {
        throw TestError.intentional
    }
}

private enum TestError: Error {
    case intentional
}
