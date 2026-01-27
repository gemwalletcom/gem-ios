// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import Primitives

internal import GemstonePrimitives

public protocol SecretPhraseViewableModel {
    var title: String { get }
    var calloutViewStyle: CalloutViewStyle? { get }
    var type: SecretPhraseDataType { get }
    var copyModel: CopyTypeViewModel { get }
    var continueAction: VoidAction { get }
    var docsUrl: URL { get }
}

public extension SecretPhraseViewableModel {
    var docsUrl: URL { Docs.url(.howToSecureSecretPhrase) }
}
