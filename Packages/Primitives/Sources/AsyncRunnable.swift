// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol AsyncRunnable: Sendable {
    var id: String { get }
    func run() async throws
}
