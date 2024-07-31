// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

class ShowSecretPhraseViewModel {
    
    private let words: [String]

    init(words: [String]) {
        self.words = words
    }
}

extension ShowSecretPhraseViewModel: SecretPhraseViewableModel {
    var title: String {
        return Localized.Common.secretPhrase
    }

    var type: SecretPhraseDataType {
        return .words(words: WordIndex.rows(for: words))
    }

    var copyValue: String {
        MnemonicFormatter.fromArray(words: words)
    }

    var copyType: CopyType {
        .secretPhrase
    }

    var presentWarning: Bool {
        return false
    }
}
