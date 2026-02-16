// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import WalletsServiceTestKit
import SwapService
import StoreTestKit
import ChainServiceTestKit
import SwapServiceTestKit
import BigInt
import protocol Gemstone.GemSwapperProtocol
import enum Gemstone.SwapperError
import Keystore
import KeystoreTestKit
import Primitives
@testable import Swap
@testable import Store

@MainActor
struct SwapSceneViewModelTests {
    @Test
    func toValue() async {
        #expect(await model().toValue == "250,000.00")
        #expect(await model(toValueMock: "1000000").toValue == "1.00")
        #expect(await model(toValueMock: "10000").toValue == "0.01")
        #expect(await model(toValueMock: "12").toValue == "0.000012")
    }
    
    @Test
    func additionalInfoVisibility() async {
        let model = SwapSceneViewModel.mock()

        model.swapState.quotes = .loading
        #expect(model.shouldShowAdditionalInfo == false)

        model.swapState.quotes = .data([.mock()])
        #expect(model.shouldShowAdditionalInfo)
	}

    @Test
    func buttonViewModelFlow() {
        let model = SwapSceneViewModel.mock()

        model.swapState.quotes = .data([])
        #expect(model.buttonViewModel.buttonAction == SwapButtonAction.swap)
        #expect(model.buttonViewModel.isVisible)

        model.swapState.quotes = .error(TestError())
        #expect(model.buttonViewModel.buttonAction == SwapButtonAction.retryQuotes)

        model.swapState.quotes = .data([])
        model.swapState.swapTransferData = .error(TestError())
        #expect(model.buttonViewModel.buttonAction == SwapButtonAction.retrySwap)
    }

    @Test
    func cancelledTaskDoesNotUpdateStateWithError() async throws {
        let swapper = GemSwapperMock(
            fetchQuoteDelay: .milliseconds(100),
            fetchQuoteError: SwapperError.NoQuoteAvailable
        )
        let model = SwapSceneViewModel.mock(swapper: swapper)

        let task = Task {
            await model.fetch()
        }

        try await Task.sleep(for: .milliseconds(50))
        task.cancel()
        await task.value

        if case .error = model.swapState.quotes {
            Issue.record("State should not be .error when Task is cancelled")
        }
    }

    @Test
    func emptyInputCancelsInFlightRequest() async throws {
        let swapper = GemSwapperMock(
            fetchQuoteDelay: .milliseconds(100),
            fetchQuoteError: SwapperError.NoQuoteAvailable
        )
        let model = SwapSceneViewModel.mock(swapper: swapper)

        let task = Task {
            await model.fetch()
        }

        try await Task.sleep(for: .milliseconds(50))
        task.cancel()
        model.swapState.quotes = .noData

        await task.value

        #expect(model.swapState.quotes.isNoData)
    }

    @Test
    func fetchTriggerIsImmediate() {
        let model = SwapSceneViewModel.mock()

        model.fetchTrigger = nil
        model.onChangeFromValue("1", "2")

        #expect(model.fetchTrigger?.isImmediate == false)

        model.fetchTrigger = nil
        model.onSelectPercent(50)

        #expect(model.fetchTrigger?.isImmediate == true)

        model.fetchTrigger = nil
        model.onChangeToAsset(old: .mock(asset: .mockEthereum()), new: .mock(asset: .mockEthereumUSDT()))

        #expect(model.fetchTrigger?.isImmediate == true)

        model.fetchTrigger = nil
        model.swapState.quotes = .error(SwapperError.NoQuoteAvailable)
        model.buttonViewModel.action()

        #expect(model.fetchTrigger?.isImmediate == true)

        model.fetchTrigger = nil
        model.swapState.quotes = .error(SwapperError.InputAmountError(minAmount: "1000000000000000000"))
        model.errorInfoAction?()

        #expect(model.fetchTrigger?.isImmediate == true)
    }

    // MARK: - Private methods

    private func model(
        toValueMock: String = "250000000000"
    ) async -> SwapSceneViewModel {
        let swapper = GemSwapperMock(quotes: [.mock(toValue: toValueMock)])
        let model = SwapSceneViewModel.mock(swapper: swapper)
        await model.fetch()
        return model
    }
}

extension SwapSceneViewModel {
    static func mock(swapper: GemSwapperProtocol = GemSwapperMock()) -> SwapSceneViewModel {
        let model = SwapSceneViewModel(
            preferences: .mock(),
            input: .init(
                wallet: .mock(accounts: [.mock(chain: .ethereum)]),
                pairSelector: SwapPairSelectorViewModel(fromAssetId: .mockEthereum(), toAssetId: nil)
            ),
            walletsService: .mock(),
            swapQuotesProvider: SwapQuotesProvider(swapService: .mock(swapper: swapper)),
            swapQuoteDataProvider: SwapQuoteDataProvider(keystore: LocalKeystore.mock(), swapService: .mock(swapper: swapper))
        )
        model.fromAssetQuery.value = .mock(asset: .mockEthereum(), balance: .mock())
        model.toAssetQuery.value = .mock(asset: .mockEthereumUSDT())
        model.amountInputModel.text = "1"

        return model
    }
}

private struct TestError: Error, RetryableError {
    var isRetryAvailable: Bool = true
}
