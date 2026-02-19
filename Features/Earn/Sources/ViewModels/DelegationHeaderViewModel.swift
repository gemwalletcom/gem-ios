// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import PrimitivesComponents
import SwiftUI

public struct DelegationHeaderViewModel: HeaderViewModel {

    private let model: DelegationViewModel

    public let isWatchWallet: Bool = false
    public let buttons: [HeaderButton] = []

    public init(model: DelegationViewModel) {
        self.model = model
    }

    public var assetImage: AssetImage? {
        model.validatorImage
    }

    public var title: String {
        model.balanceText
    }

    public var subtitle: String? {
        model.fiatValueText
    }

    public var subtitleColor: Color {
        .secondary
    }
}
