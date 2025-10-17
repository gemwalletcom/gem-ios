// Copyright (c). Gem Wallet. All rights reserved.
import Blockchain
import Foundation
import Keystore
import Primitives
import WalletCore

public struct SwapSigner {

    public init() {}

    func isTransferSwap(data: SwapData) -> Bool {
        switch data.quote.providerData.provider {
        case .nearIntents: true
        default: false
        }
    }

    func transferSwapInput(input: SignerInput, fromAsset: Asset, swapData: SwapData) throws -> SignerInput {
        let memo = getMemo(fromAsset: fromAsset, swapData: swapData)

        return SignerInput(
            type: .transfer(fromAsset),
            asset: fromAsset,
            value: swapData.quote.fromValueBigInt,
            fee: input.fee,
            isMaxAmount: input.useMaxAmount,
            memo: memo,
            senderAddress: input.senderAddress,
            destinationAddress: input.destinationAddress,
            metadata: input.metadata
        )
    }

    func getMemo(fromAsset: Asset, swapData: SwapData) -> String? {
        switch fromAsset.chain.type {
        case .stellar:
            return swapData.data.data
        default:
            return nil
        }
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
