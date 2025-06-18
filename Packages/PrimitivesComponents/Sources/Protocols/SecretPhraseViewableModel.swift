// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

public protocol SecretPhraseViewableModel {
    var title: String { get }
    var calloutViewStyle: CalloutViewStyle? { get }
    var type: SecretPhraseDataType { get }
    var copyModel: CopyTypeViewModel { get }
    var continueAction: VoidAction { get }
}
