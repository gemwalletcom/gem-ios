// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import InfoSheet
import Primitives

@Observable
@MainActor
final class TransactionSceneViewModel {
    public var isPresentingShareSheet: Bool = false
    public var isPresentingInfoSheet: InfoSheetType? = .none
    
    private let detailViewModel: TransactionDetailViewModel
    
    init(detailViewModel: TransactionDetailViewModel) {
        self.detailViewModel = detailViewModel
    }
}

// MARK: - Actions

extension TransactionSceneViewModel {
    public func onNetworkFeeInfo() {
        isPresentingInfoSheet = .networkFee(detailViewModel.chain)
    }
    
    public func onStatusInfo() {
        isPresentingInfoSheet = .transactionState(
            imageURL: detailViewModel.assetImage.imageURL,
            placeholder: detailViewModel.assetImage.placeholder,
            state: detailViewModel.transactionState
        )
    }
    
    public func onShare() {
        isPresentingShareSheet = true
    }
}