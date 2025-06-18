// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents
import Formatters
import Components

struct ShowSecretPhraseViewModel: SecretPhraseViewableModel {
    private let words: [String]

    init(words: [String]) {
        self.words = words
    }

    var calloutViewStyle: CalloutViewStyle? {
        .secretDataWarning()
    }

    var continueAction: Primitives.VoidAction = nil
    
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
}
