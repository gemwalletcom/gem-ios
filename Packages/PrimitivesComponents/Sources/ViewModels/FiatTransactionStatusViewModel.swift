// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import SwiftUI
import Localization

public struct FiatTransactionStatusViewModel: Sendable {
    let status: FiatTransactionStatus

    public init(status: FiatTransactionStatus) {
        self.status = status
    }

    public var title: String {
        switch status {
        case .complete: Localized.Transaction.Status.confirmed
        case .pending: Localized.Transaction.Status.pending
        case .failed: Localized.Transaction.Status.failed
        case .unknown(let value): value
        }
    }

    public var color: Color {
        switch status {
        case .complete: Colors.green
        case .pending: Colors.orange
        case .failed: Colors.red
        case .unknown: Colors.gray
        }
    }

    public var background: Color {
        switch status {
        case .complete: Colors.green.opacity(.light)
        case .pending: Colors.orange.opacity(.light)
        case .failed: Colors.red.opacity(.light)
        case .unknown: Colors.gray.opacity(.light)
        }
    }
}
