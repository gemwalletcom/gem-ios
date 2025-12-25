// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol OnstartAsyncRunnable: Sendable {
    func run(config: ConfigResponse?) async throws
}
