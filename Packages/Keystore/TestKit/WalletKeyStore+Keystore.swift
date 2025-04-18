// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore

public extension WalletKeyStore {
    static func mock() -> WalletKeyStore {
        let id = UUID().uuidString
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let directory = URL(fileURLWithPath: String(format: "%@/test_keystore/%@", documentsDirectory, id))

        return WalletKeyStore(
            directory: directory
        )
    }
}
