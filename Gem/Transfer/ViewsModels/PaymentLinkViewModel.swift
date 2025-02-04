// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Foundation
import Keystore
import Localization
import Primitives
import PrimitivesComponents
import SwiftUI
import Transfer

public typealias PaymentLinkAction = ((PaymentLinkData) -> Void)?

public struct PaymentLinkViewModel {
    public let data: PaymentLinkData

    init(data: PaymentLinkData) {
        self.data = data
    }
}
