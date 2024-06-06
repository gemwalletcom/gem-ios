// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Store

struct CleanUpService {
    
    let keystore: any Keystore
    let preferences: Preferences

    init(
        keystore: any Keystore,
        preferences: Preferences = .standard
    ) {
        self.keystore = keystore
        self.preferences = preferences
    }
    
    func initialSetup() throws {
        //preferences.clear()
        
//        if keystore.wallets.isEmpty {
//            try LocalKeystorePassword().remove()
//        }
    }
    
    func onDeleteAllWallets() throws {
        //preferences.clear()
        //try LocalKeystorePassword().remove()
    }
}
