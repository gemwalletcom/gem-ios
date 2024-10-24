// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct InfoSheetViewModel {
    private let type: InfoSheetType

    init(type: InfoSheetType) {
        self.type = type
    }

    var buttonTitle: String { "Learn more" }
}

// MARK: - InfoModel

extension InfoSheetViewModel: InfoModel {
    var url: URL? {
        type.url
    }

    var title: String {
        switch type {
        case .networkFees: "Network Fees"
        case .transactionStatus: "Transaction Status"
        }
    }

    var description: String {
        switch type {
        case .networkFees: "Fees paid for transaction processing, varying by network conditions."
        case .transactionStatus: "Track your transactions' status on the blockchain."
        }
    }

    var image: Image? {
        nil
//        return Image(.logo)
    }
}
