// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectSign
import Primitives

protocol WalletConnectRequestHandleable: Sendable {
    func handle(request: WalletConnectSign.Request) async throws -> RPCResult
}
