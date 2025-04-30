// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore

public extension LocalKeystore {
    static let words = ["shoot", "island", "position", "soft", "burden", "budget", "tooth", "cruel", "issue", "economy", "destroy", "above"]

    static func mock(
        keystorePassword: KeystorePassword = MockKeystorePassword()
    ) -> LocalKeystore {
        LocalKeystore(
            directory: UUID().uuidString,
            keystorePassword: keystorePassword
        )
    }
}
