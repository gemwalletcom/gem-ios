// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol Job: Sendable {
    var id: String { get }
    var configuration: JobConfiguration { get }

    func run() async -> JobStatus
    func onComplete() async throws
}
