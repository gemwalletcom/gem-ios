// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

class ShowSecretPhraseViewModel: SecretPhraseViewableModel {
    
    let words: [String]
    
    init(words: [String]) {
        self.words = words
    }
    
    var title: String {
        return Localized.Common.secretPhrase
    }
    
    var presentWarning: Bool {
        return false
    }
}
