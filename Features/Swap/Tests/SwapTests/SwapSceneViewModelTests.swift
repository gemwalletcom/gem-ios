// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import WalletsServiceTestKit
import SwapService
import Keystore
import KeystoreTestKit
import StoreTestKit
import ChainServiceTestKit
import SwapServiceTestKit
import BigInt
import protocol Gemstone.GemSwapperProtocol

@testable import Swap

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
    func swapEstimationText() async {
        let model = SwapSceneViewModel.mock()
        
        model.selectedSwapQuote = .mock(etaInSeconds: nil)
        #expect(model.swapEstimationText == nil)
        
        model.selectedSwapQuote = .mock(etaInSeconds: 30)
        #expect(model.swapEstimationText == nil)
        
        model.selectedSwapQuote = .mock(etaInSeconds: 180)
        #expect(model.swapEstimationText == "≈ 3 min")
    }
    
    @Test
    func insufficientBalance() {
        let model = SwapSceneViewModel.mock()
        model.onChangeFromAsset(old: nil, new: .mock(asset: .mockEthereum(), balance: .init(available: 1000000000000000000)))
        model.amountInputModel.text = "1.1"

        #expect(model.actionButtonState.isError)
        #expect(model.actionButtonTitle == "Insufficient ETH balance.")
        
        model.amountInputModel.text = "0.9"
        #expect(!model.actionButtonState.isError)
        #expect(model.actionButtonTitle == "Swap")
    }
    
    // MARK: - Private methods
    
    private func model(
        toValueMock: String = "250000000000"
    ) async -> SwapSceneViewModel {
        let swapper = GemSwapperMock(quotes: [.mock(toValue: toValueMock)])
        let model = SwapSceneViewModel.mock(swapper: swapper)
        await model.onFetchStateChange(state: .fetch(input: .mock(), delay: nil))
        return model
    }
}

extension SwapSceneViewModel {
    static func mock(swapper: GemSwapperProtocol = GemSwapperMock()) -> SwapSceneViewModel {
        let model = SwapSceneViewModel(
            wallet: .mock(accounts: [.mock(chain: .ethereum)]),
            asset: .mockEthereum(),
            walletsService: .mock(),
            swapService: .mock(swapper: swapper),
            keystore: LocalKeystore.mock()
        )
        
        model.fromAsset = .mock(asset: .mockEthereum())
        model.toAsset = .mock(asset: .mockEthereumUSDT())
        
        return model
    }
}

extension SwapQuoteInput {
    static func mock() -> SwapQuoteInput {
        SwapQuoteInput(
            fromAsset: .mockEthereum(),
            toAsset: .mockEthereumUSDT(),
            amount: 1000000000000000000
        )
    }
}
