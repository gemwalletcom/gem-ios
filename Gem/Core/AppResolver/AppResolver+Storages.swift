// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Store

extension AppResolver {
    struct Storages {
        let db: DB = .main
        let observablePreferences: ObservablePreferences = .default
        let keystore: any Keystore = LocalKeystore.main
        let explorerStore = ExplorerStorage.main
    }
}
