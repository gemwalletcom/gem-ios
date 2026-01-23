// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents
import Formatters
import Components

struct ShowSecretPhraseViewModel: SecretPhraseViewableModel {
    private let secretData: SecretData
    let continueAction: Primitives.VoidAction = nil

    init(secretData: SecretData) {
        self.secretData = secretData
    }

    var calloutViewStyle: CalloutViewStyle? {
        .secretDataWarning()
    }

    var title: String {
        Localized.Common.secretPhrase
    }

    var type: SecretPhraseDataType {
        .words(words: WordIndex.rows(for: secretData.words))
    }

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .secretPhrase,
            copyValue: secretData.string
        )
    }
}
