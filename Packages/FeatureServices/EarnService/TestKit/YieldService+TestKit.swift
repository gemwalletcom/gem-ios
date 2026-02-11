// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

@testable import EarnService

extension YieldService {
    public static func mock() -> YieldService {
        try! YieldService(yielder: GemYielder(rpcProvider: MockRpcProvider()))
    }
}

private final class MockRpcProvider: GemRpcProvider, @unchecked Sendable {
    func getRequest(chain: String, url: String) async throws -> String { "" }
    func postRequest(chain: String, url: String, body: String) async throws -> String { "" }
}
