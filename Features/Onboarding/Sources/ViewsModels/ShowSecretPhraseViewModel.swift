// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents

class ShowSecretPhraseViewModel {
    
    private let words: [String]

    init(words: [String]) {
        self.words = words
    }
}

extension ShowSecretPhraseViewModel: SecretPhraseViewableModel {
    var title: String {
        Localized.Common.secretPhrase
    }

    var type: SecretPhraseDataType {
        .words(words: WordIndex.rows(for: words))
    }

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .secretPhrase,
            copyValue: MnemonicFormatter.fromArray(words: words)
        )
    }

    var presentWarning: Bool {
        false
    }
}
