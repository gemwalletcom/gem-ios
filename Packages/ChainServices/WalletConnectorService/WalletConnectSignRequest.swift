// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ReownWalletKit

extension WalletConnectSign.Request {
    var messageId: String {
        "request-\(method)-\(topic)-\(id)"
    }
}
