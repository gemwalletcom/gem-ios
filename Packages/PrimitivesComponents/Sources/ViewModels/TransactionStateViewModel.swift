// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import SwiftUI
import Localization

public struct TransactionStateViewModel {
    let state: TransactionState

    public init(state: TransactionState) {
        self.state = state
    }

    public var title: String {
        switch state {
        case .confirmed: Localized.Transaction.Status.confirmed
        case .pending, .inTransit: Localized.Transaction.Status.pending
        case .failed: Localized.Transaction.Status.failed
        case .reverted: Localized.Transaction.Status.reverted
        }
    }
    
    public var description: String {
        switch state {
        case .pending, .inTransit: Localized.Info.Transaction.Pending.description
        case .confirmed: Localized.Info.Transaction.Success.description
        case .failed, .reverted: Localized.Info.Transaction.Error.description
        }
    }
    
    public var stateImage: Image {
        switch state {
        case .pending, .inTransit: Images.Transaction.State.pending
        case .confirmed: Images.Transaction.State.success
        case .failed, .reverted: Images.Transaction.State.error
        }
    }

    public var color: Color {
        switch state {
        case .confirmed: Colors.green
        case .pending, .inTransit: Colors.orange
        case .failed, .reverted: Colors.red
        }
    }

    public var background: Color {
        switch state {
        case .confirmed: Colors.green.opacity(.light)
        case .pending, .inTransit: Colors.orange.opacity(.light)
        case .failed, .reverted: Colors.red.opacity(.light)
        }
    }
}
