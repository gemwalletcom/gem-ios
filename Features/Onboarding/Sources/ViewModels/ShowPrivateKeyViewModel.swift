// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents
import Style
import Components

struct ShowPrivateKeyViewModel: SecretPhraseViewableModel {
    let secretData: SecretData
    let continueAction: VoidAction = nil

    init(secretData: SecretData) {
        self.secretData = secretData
    }

    var calloutViewStyle: CalloutViewStyle? {
        .secretDataWarning()
    }

    var title: String {
        Localized.Common.privateKey
    }

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .privateKey,
            copyValue: secretData.string
        )
    }

    var type: SecretPhraseDataType {
        .privateKey(key: secretData.string)
    }
}
