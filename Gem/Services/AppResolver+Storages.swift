// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Store
import Preferences

extension AppResolver {
    struct Storages {
        let db: DB = DB(fileName: "db.sqlite")
        let observablePreferences: ObservablePreferences = .default
        let keystore: any Keystore = LocalKeystore()
    }
}
