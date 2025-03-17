// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol SecretPhraseViewableModel {
    var title: String { get }
    var type: SecretPhraseDataType { get }
    var copyModel: CopyTypeViewModel { get }
    var presentWarning: Bool { get }
}

