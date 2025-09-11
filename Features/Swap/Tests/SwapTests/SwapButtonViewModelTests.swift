// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import Components
import Primitives
import Localization
import Style
import struct Gemstone.SwapperQuote

@testable import Swap

struct SwapButtonViewModelTests {
    
    @Test
    func retryQuotesWhenQuotesFail() {
        let swapState = SwapState(availability: .error(MockRetryableError()))
        let viewModel = SwapButtonViewModel.mock(swapState: swapState)
        
        #expect(viewModel.buttonAction == SwapButtonAction.retryQuotes)
        #expect(viewModel.title == Localized.Common.tryAgain)
        #expect(viewModel.type == ButtonType.primary(.normal))
        #expect(viewModel.isVisible == true)
    }
    
    @Test
    func retrySwapWhenTransferDataFails() {
        let swapState = SwapState(availability: .data([]), swapTransferData: .error(MockRetryableError()))
        let viewModel = SwapButtonViewModel.mock(swapState: swapState)
        
        #expect(viewModel.buttonAction == SwapButtonAction.retrySwap)
        #expect(viewModel.title == Localized.Common.tryAgain)
        #expect(viewModel.type == ButtonType.primary(.normal))
        #expect(viewModel.isVisible == true)
    }
    
    @Test
    func retrySwapShowsLoadingWhenInProgress() {
        let swapState = SwapState(availability: .data([]), swapTransferData: .loading)
        let viewModel = SwapButtonViewModel.mock(swapState: swapState)

        #expect(viewModel.type == ButtonType.primary(.loading()))
        #expect(viewModel.isVisible == true)
    }
    
    @Test
    func insufficientBalanceWhenAmountInvalid() {
        let asset = AssetData.mock(asset: .mock(symbol: "BTC"))
        let swapState = SwapState(availability: .data([]))
        let viewModel = SwapButtonViewModel.mock(swapState: swapState, isAmountValid: false, fromAsset: asset)
        
        #expect(viewModel.buttonAction == SwapButtonAction.insufficientBalance(asset: asset.asset))
        #expect(viewModel.title == Localized.Transfer.insufficientBalance("BTC"))
        #expect(viewModel.type == ButtonType.primary(.disabled))
        #expect(viewModel.isVisible == true)
    }
    
    @Test
    func swapWhenReadyToExecute() {
        let swapState = SwapState(availability: .data([]))
        let viewModel = SwapButtonViewModel.mock(swapState: swapState)
        
        #expect(viewModel.buttonAction == SwapButtonAction.swap)
        #expect(viewModel.title == Localized.Wallet.swap)
        #expect(viewModel.type == ButtonType.primary(.normal))
        #expect(viewModel.isVisible == true)
    }
    
    @Test
    func hiddenWhenNoQuotes() {
        let swapState = SwapState(availability: .noData)
        let viewModel = SwapButtonViewModel.mock(swapState: swapState)
        
        #expect(viewModel.isVisible == false)
    }
    
    @Test
    func showLoadingWhenFetchingQuotes() {
        let swapState = SwapState(availability: .loading)
        let viewModel = SwapButtonViewModel.mock(swapState: swapState)
        
        #expect(viewModel.type == ButtonType.primary(.loading()))
        #expect(viewModel.isVisible == true)
    }
    
    @Test
    func canRetryLogicEdgeCase() {
        let swapState = SwapState(
            availability: .error(MockNonRetryableError()),
            swapTransferData: .error(MockRetryableError())
        )
        let viewModel = SwapButtonViewModel.mock(swapState: swapState)
        #expect(viewModel.buttonAction == SwapButtonAction.retrySwap)
    }
}

extension SwapButtonViewModel {
    static func mock(
        swapState: SwapState = SwapState(availability: .noData),
        isAmountValid: Bool = true,
        fromAsset: AssetData? = .mock()
    ) -> SwapButtonViewModel {
        SwapButtonViewModel(
            swapState: swapState,
            isAmountValid: isAmountValid,
            fromAsset: fromAsset,
            onAction: {}
        )
    }
}

private struct MockRetryableError: Error, RetryableError {
    var isRetryAvailable: Bool = true
}

private struct MockNonRetryableError: Error {}
