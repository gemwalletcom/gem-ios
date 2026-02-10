// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

@testable import EarnService

extension EarnProviderService {
    public static func mock() -> EarnProviderService {
        try! EarnProviderService(yielder: GemYielder(rpcProvider: MockRpcProvider()))
    }
}

private final class MockRpcProvider: GemRpcProvider, @unchecked Sendable {
    func getRequest(chain: String, url: String) async throws -> String { "" }
    func postRequest(chain: String, url: String, body: String) async throws -> String { "" }
}
