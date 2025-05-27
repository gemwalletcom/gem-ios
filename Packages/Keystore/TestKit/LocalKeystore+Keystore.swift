// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore

public extension LocalKeystore {
    static let words = ["shoot", "island", "position", "soft", "burden", "budget", "tooth", "cruel", "issue", "economy", "destroy", "above"]
    static let privateKey = "Ox9f110a73d04dc7becb316fb9adfe04689a947bb49be11060577c3c0a4b4d4cd5"
    static let address = "0x734dc149d4c7d0d5e95b5aa787e5fb288dd167a9"

    static func mock(
        keystorePassword: KeystorePassword = MockKeystorePassword()
    ) -> LocalKeystore {
        LocalKeystore(
            directory: UUID().uuidString,
            keystorePassword: keystorePassword
        )
    }
}
