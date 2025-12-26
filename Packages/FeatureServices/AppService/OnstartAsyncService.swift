// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct OnstartAsyncService: Sendable {

    private let configService: any GemAPIConfigService
    private let runners: [any OnstartAsyncRunnable]

    public init(
        configService: any GemAPIConfigService,
        runners: [any OnstartAsyncRunnable]
    ) {
        self.configService = configService
        self.runners = runners
    }

    public func run() async {
        let config = try? await configService.getConfig()

        for runner in runners {
            do {
                try await runner.run(config: config)
            } catch {
                debugLog("\(type(of: runner)) failed: \(error)")
            }
        }
    }
}
