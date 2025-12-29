// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct OnstartAsyncService: Sendable {

    private let runners: [any AsyncRunnable]

    public init(runners: [any AsyncRunnable]) {
        self.runners = runners
    }

    public func run() async {
        for runner in runners {
            do {
                try await runner.run()
            } catch {
                debugLog("\(runner.id) failed: \(error)")
            }
        }
    }
}
