// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Transfer
import PrimitivesComponents

public typealias PaymentLinkAction = ((PaymentLinkData) -> Void)?

public struct PaymentLinkData: Hashable {
    public let label: String
    public let logo: String
    public let chain: Chain
    public let transaction: String
}

public struct PaymentLinkViewModel {
    public let data: PaymentLinkData

    init(data: PaymentLinkData) {
        self.data = data
    }
}
