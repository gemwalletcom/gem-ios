// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Style
import Components
import Primitives
import SwiftUI
import PrimitivesComponents
import struct Gemstone.SwapperQuote

enum SwapButtonAction: Equatable {
    case retryQuotes
    case retrySwap
    case insufficientBalance(asset: Asset)
    case swap
}

struct SwapButtonViewModel: StateButtonViewable {
    private let swapState: SwapState
    private let isAmountValid: Bool
    private let fromAsset: AssetData?

    private let perform: @MainActor @Sendable () -> Void

    init(
        swapState: SwapState,
        isAmountValid: Bool,
        fromAsset: AssetData?,
        onAction: @MainActor @Sendable @escaping () -> Void
    ) {
        self.swapState = swapState
        self.isAmountValid = isAmountValid
        self.fromAsset = fromAsset
        self.perform = onAction
    }

    var title: String {
        switch buttonAction {
        case .retryQuotes, .retrySwap: Localized.Common.tryAgain
        case .insufficientBalance(let asset): Localized.Transfer.insufficientBalance(asset.symbol)
        case .swap: Localized.Wallet.swap
        }
    }

    var buttonAction: SwapButtonAction {
        if canRetryQuotes { return .retryQuotes }
        if canRetrySwap { return .retrySwap }
        if !isAmountValid, let fromAsset { return .insufficientBalance(asset: fromAsset.asset) }
        return .swap
    }

    var icon: Image? { nil }
    var type: ButtonType {
        switch buttonAction {
        case .retryQuotes: swapState.quotes.isLoading ? .primary(swapState.quotes) : .primary(.normal)
        case .insufficientBalance: .primary(.disabled)
        case .retrySwap: swapState.swapTransferData.isLoading ? .primary(swapState.swapTransferData) : .primary(.normal)
        case .swap: swapState.swapTransferData.isLoading ? .primary(swapState.swapTransferData) : .primary(swapState.quotes)
        }
    }
    var isVisible: Bool { !swapState.quotes.isNoData }

    func action() { perform() }
}

// MARK: - Private

extension SwapButtonViewModel {
    private var canRetryQuotes: Bool {
        guard case .error(let error) = swapState.quotes,
              let retryableError = error as? RetryableError else { return false }
        return retryableError.isRetryAvailable
    }

    private var canRetrySwap: Bool {
        guard case .error(let error) = swapState.swapTransferData,
              let retryableError = error as? RetryableError else { return false }
        return retryableError.isRetryAvailable
    }
}
