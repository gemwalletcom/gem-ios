// Copyright (c). Gem Wallet. All rights reserved.
import Blockchain
import Foundation
import Keystore
import Primitives
import WalletCore

public struct SwapSigner {
    public init() {}

    func isTransferSwap(fromAsset: Asset, data: SwapData) -> Bool {
        switch data.data.dataType {
        case .transfer: true
        case .contract: false
        }
    }

    func transferSwapInput(input: SignerInput, fromAsset: Asset, swapData: SwapData) throws -> SignerInput {
        SignerInput(
            type: .transfer(fromAsset),
            asset: fromAsset,
            value: swapData.quote.fromValueBigInt,
            fee: input.fee,
            isMaxAmount: input.useMaxAmount,
            memo: swapData.data.memo,
            senderAddress: input.senderAddress,
            destinationAddress: swapData.data.to,
            metadata: input.metadata
        )
    }

    func signSwap(signer: Signable, input: SignerInput, fromAsset: Asset, swapData: SwapData, privateKey: Data) throws -> [String] {
        let transferInput = try transferSwapInput(
            input: input,
            fromAsset: fromAsset,
            swapData: swapData
        )
        switch fromAsset.id.type {
        case .native:
            return try [signer.signTransfer(input: transferInput, privateKey: privateKey)]
        case .token:
            return try [signer.signTokenTransfer(input: transferInput, privateKey: privateKey)]
        }
    }
}
