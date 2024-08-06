// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

protocol SecretPhraseViewableModel {
    var title: String { get }
    var type: SecretPhraseDataType { get }
    var copyValue: String { get }
    var copyType: CopyType { get }
    var presentWarning: Bool { get }
}

