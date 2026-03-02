// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import WalletConnectorService
import WalletConnectorServiceTestKit

@testable import WalletConnector

struct TransferDataCallbackTests {

    typealias DelegateResult = Result<String, any Error>

    @Test
    func delegateCallsOnce() async {
        await confirmation(expectedCount: 1) { confirm in
            let callback = TransferDataCallback(payload: SignMessagePayload.mock()) { result in
                #expect((try? result.get()) == "first")
                confirm()
            }
            callback.delegate(DelegateResult.success("first"))
            callback.delegate(DelegateResult.success("second"))
            callback.delegate(DelegateResult.failure(AnyError("test")))
        }
    }
}
