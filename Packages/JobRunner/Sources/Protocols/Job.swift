// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol Job: Sendable {
    var id: String { get }

    func run() async -> JobStatus
}
