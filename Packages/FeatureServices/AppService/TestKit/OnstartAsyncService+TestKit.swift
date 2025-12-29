// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import Primitives

public extension OnstartAsyncService {
    static func mock(runners: [any AsyncRunnable] = []) -> OnstartAsyncService {
        OnstartAsyncService(runners: runners)
    }
}
