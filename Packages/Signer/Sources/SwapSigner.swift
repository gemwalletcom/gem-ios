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
        let destinationAddress = try getDestinationAddress(fromAsset: fromAsset, swapData: swapData)

        return SignerInput(
            type: .transfer(fromAsset),
            asset: fromAsset,
            value: swapData.quote.fromValueBigInt,
            fee: input.fee,
            isMaxAmount: input.useMaxAmount,
            memo: memo,
            senderAddress: input.senderAddress,
            destinationAddress: destinationAddress,
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

    func getDestinationAddress(fromAsset: Asset, swapData: SwapData) throws -> String {
        guard fromAsset.tokenId != nil else {
            return swapData.data.to
        }
        switch fromAsset.chain.type {
        case .ethereum:
            let addressData = try extractTokenDestination(from: swapData.data.data)
            return addressData.hexString.append0x
        case .tron:
            let addressData = try extractTokenDestination(from: swapData.data.data)
            return try tronAddress(from: addressData)
        default:
            return swapData.data.to
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

    private func extractTokenDestination(from callDataHex: String) throws -> Data {
        guard let callData = Data(fromHex: callDataHex), callData.count == 68 else {
            throw AnyError("Invalid Call data")
        }
        let addressSlice = callData[4 ..< 36]
        let destinationSlice = addressSlice.suffix(20)
        return Data(destinationSlice)
    }

    private func tronAddress(from addressData: Data) throws -> String {
        guard addressData.count == 20 else {
            throw AnyError("Invalid Tron address length")
        }

        var payload = Data([0x41])
        payload.append(addressData)

        return Base58.encode(data: payload)
    }
}
