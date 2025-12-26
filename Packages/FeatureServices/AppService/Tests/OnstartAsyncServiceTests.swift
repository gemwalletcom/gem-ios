import Foundation
import Testing
import GemAPITestKit
import AppServiceTestKit
import Primitives
import PrimitivesTestKit

@testable import AppService

struct OnstartAsyncServiceTests {

    @Test
    func run() async throws {
        let service = OnstartAsyncService.mock()
        await service.run()
    }

    @Test
    func runWithRunners() async throws {
        let service = OnstartAsyncService.mock(
            runners: [
                BannerSetupRunner.mock(),
                NodeImportRunner.mock()
            ]
        )
        await service.run()
    }

    @Test
    func failingRunnerDoesNotStopOthers() async throws {
        let tracker = RunnerTracker()
        let service = OnstartAsyncService.mock(
            runners: [
                TrackingRunner(tracker: tracker, id: "first"),
                FailingRunner(),
                TrackingRunner(tracker: tracker, id: "last")
            ]
        )

        await service.run()

        #expect(await tracker.executedRunners == ["first", "last"])
    }

    @Test
    func configIsPassedToRunners() async throws {
        let tracker = RunnerTracker()
        let config = ConfigResponse.mock(versions: .mock(fiatOnRampAssets: 99))
        let service = OnstartAsyncService.mock(
            configService: GemAPIConfigServiceMock(config: config),
            runners: [ConfigCapturingRunner(tracker: tracker)]
        )

        await service.run()

        #expect(await tracker.capturedConfig?.versions.fiatOnRampAssets == 99)
    }
}

private actor RunnerTracker {
    var executedRunners: [String] = []
    var capturedConfig: ConfigResponse?

    func track(id: String) {
        executedRunners.append(id)
    }

    func capture(config: ConfigResponse?) {
        capturedConfig = config
    }
}

private struct TrackingRunner: OnstartAsyncRunnable {
    let tracker: RunnerTracker
    let id: String

    func run(config: ConfigResponse?) async throws {
        await tracker.track(id: id)
    }
}

private struct FailingRunner: OnstartAsyncRunnable {
    func run(config: ConfigResponse?) async throws {
        throw NSError(domain: "test", code: 1)
    }
}

private struct ConfigCapturingRunner: OnstartAsyncRunnable {
    let tracker: RunnerTracker

    func run(config: ConfigResponse?) async throws {
        await tracker.capture(config: config)
    }
}
