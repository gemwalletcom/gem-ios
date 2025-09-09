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
    case insufficientBalance(String)
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
        case .insufficientBalance(let symbol): Localized.Transfer.insufficientBalance(symbol)
        case .swap: Localized.Wallet.swap
        }
    }

    var buttonAction: SwapButtonAction {
        if case .error = swapState.quotes, canRetry { return .retryQuotes }
        if case .error = swapState.swapTransferData, canRetry { return .retrySwap }
        if !isAmountValid, let fromAsset { return .insufficientBalance(fromAsset.asset.symbol) }
        return .swap
    }

    var icon: Image? { nil }
    var type: ButtonType {
        if case .error = swapState.swapTransferData, canRetry {
            return .primary(.normal)
        }
        return .primary(swapState.quotes, isDisabled: !isAmountValid && !canRetry)
    }
    var isVisible: Bool { !swapState.quotes.isNoData }

    func action() { perform() }
}

// MARK: - Private

extension SwapButtonViewModel {
    private var canRetry: Bool {
        if let swapError = swapState.error as? RetryableError, swapError.isRetryAvailable {
            return true
        }
        if case .error(let quotesError) = swapState.quotes,
           let retryableError = quotesError as? RetryableError,
           retryableError.isRetryAvailable {
            return true
        }
        return false
    }

}
