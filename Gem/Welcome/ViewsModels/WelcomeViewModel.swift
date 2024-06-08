// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Settings
import Keystore
import GemstonePrimitives

struct WelcomeViewModel {
    
    let keystore: any Keystore
    
    init(
        keystore: any Keystore
    ) {
        self.keystore = keystore
    }
    
    var title: String {
        return Localized.Welcome.title
    }
    
//    var legalText: String {
//        Localized.Welcome.Legal.concent(
//            PublicConstants.url(.termsOfService).absoluteString,
//            PublicConstants.url(.privacyPolicy).absoluteString
//        )
//    }
}
