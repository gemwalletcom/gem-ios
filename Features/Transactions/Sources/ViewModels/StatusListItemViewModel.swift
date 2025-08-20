// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style
import PrimitivesComponents
import Primitives
import Localization
import SwiftUI
import Components

struct StatusListItemViewModel: ListItemViewModelRepresentable {
    let state: TransactionState
    let assetImage: AssetImage
    let infoAction: VoidAction

    init(
        state: TransactionState,
        assetImage: AssetImage,
        infoAction: VoidAction = nil
    ) {
        self.state = state
        self.assetImage = assetImage
        self.infoAction = infoAction
    }

    var title: String {
        Localized.Transaction.status
    }

    var value: String {
        TransactionStateViewModel(state: state).title
    }

    var style: TextStyle {
        let color: Color = {
            switch state {
            case .confirmed: Colors.green
            case .pending: Colors.orange
            case .failed, .reverted: Colors.red
            }
        }()
        return TextStyle(font: .callout, color: color)
    }

    var showProgress: Bool {
        state == .pending
    }
}
