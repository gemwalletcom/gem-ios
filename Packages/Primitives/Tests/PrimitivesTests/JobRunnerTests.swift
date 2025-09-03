// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import Primitives

struct JobRunnerTests {
/* TODO: - FIX a problem with CI and and async Task.sleep
    @Test
    func jobCompletes() async {
        let job = MockJob(
            completeAfter: 1,
            configuration: .fixed(duration: .milliseconds(5))
        )
        let runner = JobRunner()

        await runner.addJob(job: job)
        try? await Task.sleep(for: .milliseconds(10))

        #expect(job.runCount == 1)
        #expect(job.completed)
    }

    @Test
    func jobRetriesFixed() async {
        let job = MockJob(
            completeAfter: 3,
            configuration: .fixed(duration: .milliseconds(5))
        )
        let runner = JobRunner()

        await runner.addJob(job: job)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(job.runCount == 3)
        #expect(job.completed)
    }

    @Test
    func jobRetriesAdaptive() async {
        let job = MockJob(
            completeAfter: 3,
            configuration: .adaptive(
                configuration: AdaptiveConfiguration(
                    initialInterval: .milliseconds(5),
                    maxInterval: .milliseconds(20),
                    stepFactor: 2.0
                ),
                timeLimit: .none
            )
        )
        let runner = JobRunner()

        await runner.addJob(job: job)
        try? await Task.sleep(for: .milliseconds(80))

        #expect(job.runCount == 3)
        #expect(job.completed)
    }

    @Test
    func jobRespectsTimeLimit() async {
        let job = MockJob(
            completeAfter: 100,
            configuration: .fixed(duration: .milliseconds(5), timeLimit: .milliseconds(20))
        )
        let runner = JobRunner()

        await runner.addJob(job: job)
        try? await Task.sleep(for: .milliseconds(30))

        #expect(job.runCount > 0)
        #expect(job.runCount < 100)
        #expect(!job.completed)
    }

    @Test
    func jobCancels() async {
        let job = MockJob(
            completeAfter: 100,
            configuration: .fixed(duration: .milliseconds(5))
        )
        let runner = JobRunner()

        await runner.addJob(job: job)
        await runner.cancelJob(id: job.id)
        try? await Task.sleep(for: .milliseconds(10))

        #expect(job.runCount <= 1)
        #expect(!job.completed)
    }
 */
}

// MARK: - Mock

private final class MockJob: Job, @unchecked Sendable {
    let id = UUID().uuidString
    let configuration: JobConfiguration
    let completeAfter: Int

    private(set) var runCount = 0
    private(set) var completed = false

    init(completeAfter: Int, configuration: JobConfiguration) {
        self.completeAfter = completeAfter
        self.configuration = configuration
    }

    func run() async -> JobStatus {
        runCount += 1
        if runCount >= completeAfter {
            completed = true
            return .complete
        }
        return .retry
    }

    func onComplete() async throws {}
}
