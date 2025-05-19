// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents

struct ShowPrivateKeyViewModel {
    let text: String

    init(text: String) {
        self.text = text
    }
}

extension ShowPrivateKeyViewModel: SecretPhraseViewableModel {
    var title: String {
        Localized.Common.privateKey
    }

    var presentWarning: Bool {
        true
    }

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .privateKey,
            copyValue: text
        )
    }
    var type: SecretPhraseDataType {
        .privateKey(key: text)
    }
}
