// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesTestKit
@testable import Signer
import Testing

private let swapTestPrivateKey = Data(repeating: 0x11, count: 32)

private enum TestValues {
    static let ethereumSender = "0x1111111111111111111111111111111111111111"
    static let ethereumReceiver = "0x2222222222222222222222222222222222222222"
    static let ethereumAggregator = "0x3333333333333333333333333333333333333333"
    static let nearSender = "sender.near"
    static let nearReceiver = "receiver.near"
    static let suiSender = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    static let suiReceiver = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    static let tronSender = "TMwFHYXLJaRUPeW6421aqXL4ZEzPRFGkGT"
    static let tronAggregator = "TJApZYJwPKuQR7tL6FmvD6jDjbYpHESZGH"
    static let tronDestinationHex = "4199066fd9daa7a14e000f63b8803138607dc00aaa"
    static let tronDestination = "TPvL6et9hcRMb3j9vzVQRtt4UC2HvQrmCK"
    static let tronTokenId = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
}

struct SwapSignerTests {
    private func makeSwapInput(
        from fromAsset: Asset,
        to toAsset: Asset,
        swapData: SwapData,
        metadata: TransactionLoadMetadata = .none,
        useMaxAmount: Bool,
        senderAddress: String? = nil,
        destinationAddress: String? = nil
    ) -> SignerInput {
        SignerInput(
            type: .swap(fromAsset, toAsset, swapData),
            asset: fromAsset,
            value: swapData.quote.fromValueBigInt,
            fee: .mock(),
            isMaxAmount: useMaxAmount,
            memo: nil,
            senderAddress: senderAddress ?? swapData.quote.fromAddress,
            destinationAddress: destinationAddress ?? swapData.quote.toAddress,
            metadata: metadata
        )
    }

    private func makeSwapData(
        walletAddress: String,
        toAddress: String,
        destinationAddress: String,
        data: String,
        fromValue: String = "1000",
        useMaxAmount: Bool = false
    ) -> SwapData {
        SwapData(
            quote: SwapQuote(
                fromAddress: walletAddress,
                fromValue: fromValue,
                toAddress: destinationAddress,
                toValue: "2000",
                providerData: SwapProviderData(
                    provider: .nearIntents,
                    name: "Near Intents",
                    protocolName: "near_intents"
                ),
                slippageBps: 50,
                etaInSeconds: 60,
                useMaxAmount: useMaxAmount
            ),
            data: SwapQuoteData(
                to: toAddress,
                value: "0",
                data: data,
                memo: nil,
                approval: nil,
                gasLimit: nil
            )
        )
    }

    @Test
    func ethereumNativeTransferSwapUsesTransferFlow() throws {
        let fromAsset = Asset.mockEthereum()
        let toAsset = Asset.mockNear()
        let swapData = makeSwapData(
            walletAddress: TestValues.ethereumSender,
            toAddress: TestValues.ethereumReceiver,
            destinationAddress: TestValues.ethereumReceiver,
            data: "0x"
        )
        let input = makeSwapInput(
            from: fromAsset,
            to: toAsset,
            swapData: swapData,
            useMaxAmount: true,
            senderAddress: TestValues.ethereumSender
        )
        let mockSigner = SwapSignableMock()
        let swapSigner = SwapSigner()

        let result = try swapSigner.signSwap(
            signer: mockSigner,
            input: input,
            fromAsset: fromAsset,
            swapData: swapData,
            privateKey: swapTestPrivateKey
        )

        #expect(result == [mockSigner.transferResult])
        #expect(mockSigner.transferInputs.count == 1)
        #expect(mockSigner.tokenTransferInputs.isEmpty)

        let transfer_input = mockSigner.transferInputs.first!
        #expect(transfer_input.asset == fromAsset)
        if case .transfer(let asset) = transfer_input.type {
            #expect(asset == fromAsset)
        } else {
            #expect(Bool(false))
        }
        #expect(transfer_input.destinationAddress == swapData.data.to)
        #expect(transfer_input.memo == nil)
        #expect(transfer_input.useMaxAmount == true)
        #expect(transfer_input.value == swapData.quote.fromValueBigInt)
    }

    @Test
    func erc20TransferSwapUsesTokenTransferAndParsesDestination() throws {
        let fromAsset = Asset.mockEthereumUSDT()
        let toAsset = Asset.mockNear()
        let destinationAddress = "0x016606acc6b0cfe537acc221e3bf1bb44b4049ee"
        let callData = "0xa9059cbb000000000000000000000000016606acc6b0cfe537acc221e3bf1bb44b4049ee0000000000000000000000000000000000000000000000000000000003197500"

        let swapData = try makeSwapData(
            walletAddress: TestValues.ethereumSender,
            toAddress: fromAsset.getTokenId(),
            destinationAddress: destinationAddress,
            data: callData
        )
        let input = makeSwapInput(
            from: fromAsset,
            to: toAsset,
            swapData: swapData,
            useMaxAmount: false,
            senderAddress: TestValues.ethereumSender,
            destinationAddress: destinationAddress
        )
        let mockSigner = SwapSignableMock()
        let swapSigner = SwapSigner()

        let result = try swapSigner.signSwap(
            signer: mockSigner,
            input: input,
            fromAsset: fromAsset,
            swapData: swapData,
            privateKey: swapTestPrivateKey
        )

        #expect(result == [mockSigner.tokenTransferResult])
        #expect(mockSigner.transferInputs.isEmpty)
        #expect(mockSigner.tokenTransferInputs.count == 1)

        let transfer_input = mockSigner.tokenTransferInputs.first!

        #expect(transfer_input.asset == fromAsset)
        if case .transfer(let asset) = transfer_input.type {
            #expect(asset == fromAsset)
        } else {
            #expect(Bool(false))
        }
        #expect(transfer_input.memo == nil)
        #expect(transfer_input.useMaxAmount == false)
        #expect(transfer_input.value == swapData.quote.fromValueBigInt)
        #expect(transfer_input.destinationAddress != swapData.data.to)
        #expect(transfer_input.destinationAddress == swapData.quote.toAddress)
    }

    @Test
    func trc20TransferSwapUsesTokenTransferAndParsesBase58Destination() throws {
        let fromAsset = Asset.mockTronUSDT()
        let toAsset = Asset.mockNear()
        let functionSelector = "a9059cbb"
        let paddedDestination = TestValues.tronDestinationHex.addPadding(number: 64, padding: "0")
        let paddedAmount = String(repeating: "0", count: 63) + "1"
        let callData = "0x" + functionSelector + paddedDestination + paddedAmount
        let swapData = makeSwapData(
            walletAddress: TestValues.tronSender,
            toAddress: TestValues.tronAggregator,
            destinationAddress: TestValues.tronDestination,
            data: callData
        )
        let input = makeSwapInput(
            from: fromAsset,
            to: toAsset,
            swapData: swapData,
            useMaxAmount: false,
            senderAddress: TestValues.tronSender
        )
        let mockSigner = SwapSignableMock()
        let swapSigner = SwapSigner()

        let result = try swapSigner.signSwap(
            signer: mockSigner,
            input: input,
            fromAsset: fromAsset,
            swapData: swapData,
            privateKey: swapTestPrivateKey
        )

        #expect(result == [mockSigner.tokenTransferResult])
        #expect(mockSigner.transferInputs.isEmpty)
        #expect(mockSigner.tokenTransferInputs.count == 1)

        let transfer_input = mockSigner.tokenTransferInputs.first!
        #expect(transfer_input.asset == fromAsset)
        if case .transfer(let asset) = transfer_input.type {
            #expect(asset == fromAsset)
        } else {
            #expect(Bool(false))
        }
        #expect(transfer_input.memo == nil)
        #expect(transfer_input.useMaxAmount == false)
        #expect(transfer_input.value == swapData.quote.fromValueBigInt)
        #expect(transfer_input.destinationAddress == TestValues.tronDestination)
        #expect(transfer_input.destinationAddress != swapData.data.to)
    }

    @Test
    func nearTransferSwapKeepsMetadataAndUsesTransfer() throws {
        let fromAsset = Asset.mockNear()
        let toAsset = Asset.mockEthereum()
        let swapData = makeSwapData(
            walletAddress: TestValues.nearSender,
            toAddress: TestValues.nearReceiver,
            destinationAddress: TestValues.nearReceiver,
            data: "0x"
        )
        let metadata: TransactionLoadMetadata = .near(
            sequence: 42,
            blockHash: "near-block-hash"
        )
        let input = makeSwapInput(
            from: fromAsset,
            to: toAsset,
            swapData: swapData,
            metadata: metadata,
            useMaxAmount: false,
            senderAddress: TestValues.nearSender,
            destinationAddress: TestValues.nearReceiver
        )
        let mockSigner = SwapSignableMock()
        let swapSigner = SwapSigner()

        let result = try swapSigner.signSwap(
            signer: mockSigner,
            input: input,
            fromAsset: fromAsset,
            swapData: swapData,
            privateKey: swapTestPrivateKey
        )

        #expect(result == [mockSigner.transferResult])
        #expect(mockSigner.transferInputs.count == 1)
        #expect(mockSigner.tokenTransferInputs.isEmpty)

        guard let captured = mockSigner.transferInputs.first else {
            #expect(Bool(false))
            return
        }

        #expect(captured.destinationAddress == swapData.data.to)
        #expect(captured.value == swapData.quote.fromValueBigInt)

        if case .near(let sequence, let blockHash) = captured.metadata {
            #expect(sequence == 42)
            #expect(blockHash == "near-block-hash")
        } else {
            #expect(Bool(false))
        }
    }

    @Test
    func suiTransferSwapUsesTransferFlow() throws {
        let fromAsset = Asset.mockSUI()
        let toAsset = Asset.mockEthereum()
        let swapData = makeSwapData(
            walletAddress: TestValues.suiSender,
            toAddress: TestValues.suiReceiver,
            destinationAddress: TestValues.suiReceiver,
            data: "0x"
        )
        let metadata: TransactionLoadMetadata = .sui(messageBytes: "payload")
        let input = makeSwapInput(
            from: fromAsset,
            to: toAsset,
            swapData: swapData,
            metadata: metadata,
            useMaxAmount: false,
            senderAddress: TestValues.suiSender,
            destinationAddress: TestValues.suiReceiver
        )
        let mockSigner = SwapSignableMock()
        let swapSigner = SwapSigner()

        let result = try swapSigner.signSwap(
            signer: mockSigner,
            input: input,
            fromAsset: fromAsset,
            swapData: swapData,
            privateKey: swapTestPrivateKey
        )

        #expect(result == [mockSigner.transferResult])
        #expect(mockSigner.transferInputs.count == 1)
        #expect(mockSigner.tokenTransferInputs.isEmpty)

        guard let captured = mockSigner.transferInputs.first else {
            #expect(Bool(false))
            return
        }

        #expect(captured.destinationAddress == swapData.data.to)
        #expect(captured.value == swapData.quote.fromValueBigInt)

        if case .sui(let messageBytes) = captured.metadata {
            #expect(messageBytes == "payload")
        } else {
            #expect(Bool(false))
        }
    }
}

private final class SwapSignableMock: Signable {
    var transferInputs: [SignerInput] = []
    var tokenTransferInputs: [SignerInput] = []
    let transferResult: String
    let tokenTransferResult: String

    init(
        transferResult: String = "transfer-signature",
        tokenTransferResult: String = "token-transfer-signature"
    ) {
        self.transferResult = transferResult
        self.tokenTransferResult = tokenTransferResult
    }

    func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        transferInputs.append(input)
        return transferResult
    }

    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        tokenTransferInputs.append(input)
        return tokenTransferResult
    }
}
