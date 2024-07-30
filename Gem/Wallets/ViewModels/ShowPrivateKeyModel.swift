// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

class ShowPrivateKeyModel {

    let text: String
    let encoding: EncodingType

    init(text: String, encoding: EncodingType) {
        self.text = text
        self.encoding = encoding
    }
    
    var title: String {
        return Localized.Common.privateKey
    }
    
    var presentWarning: Bool {
        return true
    }
}
