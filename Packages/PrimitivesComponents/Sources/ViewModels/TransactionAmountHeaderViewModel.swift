// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Primitives
import Style

struct TransactionAmountHeaderViewModel: HeaderViewModel {

    let display: AmountDisplay

    let isWatchWallet: Bool = false
    let buttons: [HeaderButton] = []

    var assetImage: AssetImage? {
        display.assetImage
    }

    var title: String {
        display.amount.text
    }

    var subtitle: String? {
        display.fiat?.text
    }

    var subtitleColor: Color { Colors.gray }
}
