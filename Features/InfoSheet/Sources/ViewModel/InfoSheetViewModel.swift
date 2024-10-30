// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives

public struct InfoSheetViewModel {
    private let type: InfoSheetType

    public init(type: InfoSheetType) {
        self.type = type
    }
}

// MARK: - InfoModel

extension InfoSheetViewModel: InfoSheetModelViewable {
    public var url: URL? {
        switch type {
        case .networkFees: Docs.url(.networkFees)
        case .transactionStatus: Docs.url(.transactionStatus)
        }
    }

    public var title: String {
        switch type {
        case .networkFees: "Network Fees"
        case .transactionStatus: "Transaction Status"
        }
    }

    public var description: String {
        switch type {
        case .networkFees: "Fees paid for transaction processing, varying by network conditions."
        case .transactionStatus: "Track your transactions' status on the blockchain."
        }
    }

    public var image: Image? {
        nil
    }
    
    public var buttonTitle: String { "Learn more" }
}
