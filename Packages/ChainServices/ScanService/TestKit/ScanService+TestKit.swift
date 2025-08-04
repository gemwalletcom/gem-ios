// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ScanService
import Primitives
import Preferences
import PreferencesTestKit
import GemAPI

public extension ScanService {
    static func mock() -> ScanService {
        ScanService(
            apiService: GemAPIScanServiceMock(),
            securePreferences: SecurePreferences.mock()
        )
    }
}

private struct GemAPIScanServiceMock: GemAPIScanService {
    func getScanTransaction(payload: ScanTransactionPayload) async throws -> ScanTransaction {
        ScanTransaction(isMalicious: false, isMemoRequired: false)
    }
}
