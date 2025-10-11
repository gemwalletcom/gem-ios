// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style

public struct TransactionStatusViewModel {
    private let title: String
    private let state: TransactionState
    private let swapResult: SwapResult?
    private let onInfoAction: VoidAction

    public init(
        title: String = Localized.Transaction.status,
        state: TransactionState,
        swapResult: SwapResult? = nil,
        onInfoAction: VoidAction
    ) {
        self.title = title
        self.state = state
        self.swapResult = swapResult
        self.onInfoAction = onInfoAction
    }

    private var stateViewModel: TransactionStateViewModel {
        TransactionStateViewModel(state: state)
    }

    private var swapStateViewModel: TransactionStateViewModel? {
        guard let swapResult else { return nil }
        let mappedState: TransactionState = {
            switch swapResult.status {
            case .pending: .pending
            case .completed: .confirmed
            case .failed: .failed
            case .refunded: .failed
            }
        }()
        return TransactionStateViewModel(state: mappedState)
    }

    private var statusTitle: String {
        if let swapResult {
            switch swapResult.status {
            case .pending: return Localized.Transaction.Status.pending
            case .completed: return Localized.Transaction.Status.confirmed
            case .failed: return Localized.Transaction.Status.failed
            case .refunded: return Localized.Transaction.Status.refunded
            }
        }
        return stateViewModel.title
    }

    private var statusColor: Color {
        swapStateViewModel?.color ?? stateViewModel.color
    }

    private var statusBackground: Color {
        swapStateViewModel?.background ?? stateViewModel.background
    }

    private var statusTag: TitleTagType {
        if swapResult?.status == .pending || (swapResult == nil && state == .pending) {
            return .progressView()
        }
        let image = (swapStateViewModel ?? stateViewModel).stateImage
        return .image(image)
    }
}

// MARK: - ItemModelProvidable

extension TransactionStatusViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        .listItem(ListItemModel(
            title: title,
            titleTagType: statusTag,
            subtitle: statusTitle,
            subtitleStyle: TextStyle(font: .callout, color: statusColor, background: statusBackground),
            infoAction: onInfoAction
        ))
    }
}
