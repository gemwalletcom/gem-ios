// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ShowPrivateKeyViewModel {

    let text: String
    let encoding: EncodingType

    init(text: String, encoding: EncodingType) {
        self.text = text
        self.encoding = encoding
    }
}

extension ShowPrivateKeyViewModel: SecretPhraseViewableModel {
    var title: String {
        return Localized.Common.privateKey
    }

    var presentWarning: Bool {
        return true
    }

    var type: SecretPhraseDataType {
        .privateKey(key: text)
    }

    var copyValue: String {
        text
    }

    var copyType: CopyType {
        .privateKey
    }
}
