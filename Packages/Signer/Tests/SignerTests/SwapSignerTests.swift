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
    static let tronDestinationHex = "357a7401a0f0c2d4a44a1881a0c622f15d986291"
    static let tronDestination = "TEqyWRKCzREYC2bK2fc3j7pp8XjAa6tJK1"
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
            senderAddress: senderAddress ?? swapData.quote.walletAddress,
            destinationAddress: destinationAddress ?? swapData.data.to,
            metadata: metadata
        )
    }

    private func makeSwapData(
        walletAddress: String,
        to destination: String,
        data: String,
        fromValue: String = "1000"
    ) -> SwapData {
        SwapData(
            quote: SwapQuote(
                fromValue: fromValue,
                toValue: "2000",
                providerData: SwapProviderData(
                    provider: .nearIntents,
                    name: "Near Intents",
                    protocolName: "near_intents"
                ),
                walletAddress: walletAddress,
                slippageBps: 50,
                etaInSeconds: 60
            ),
            data: SwapQuoteData(
                to: destination,
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
        let fromAsset = Asset(
            id: AssetId(chain: .ethereum, tokenId: nil),
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            type: .native
        )
        let toAsset = Asset(
            id: AssetId(chain: .near, tokenId: nil),
            name: "NEAR",
            symbol: "NEAR",
            decimals: 24,
            type: .native
        )
        let swapData = makeSwapData(
            walletAddress: TestValues.ethereumSender,
            to: TestValues.ethereumReceiver,
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

        guard let captured = mockSigner.transferInputs.first else {
            #expect(Bool(false))
            return
        }

        #expect(captured.asset == fromAsset)
        if case .transfer(let asset) = captured.type {
            #expect(asset == fromAsset)
        } else {
            #expect(Bool(false))
        }
        #expect(captured.destinationAddress == swapData.data.to)
        #expect(captured.memo == nil)
        #expect(captured.useMaxAmount == true)
        #expect(captured.value == swapData.quote.fromValueBigInt)
    }

    @Test
    func erc20TransferSwapUsesTokenTransferAndParsesDestination() throws {
        let fromAsset = Asset(
            id: AssetId(chain: .ethereum, tokenId: "0xToken"),
            name: "Mock Token",
            symbol: "MTK",
            decimals: 18,
            type: .erc20
        )
        let toAsset = Asset(
            id: AssetId(chain: .near, tokenId: nil),
            name: "NEAR",
            symbol: "NEAR",
            decimals: 24,
            type: .native
        )
        let destination = "1234567890abcdef1234567890abcdef12345678"
        let functionSelector = "a9059cbb"
        let paddedDestination = String(repeating: "0", count: 24) + destination
        let paddedAmount = String(repeating: "0", count: 63) + "1"
        let callData = "0x" + functionSelector + paddedDestination + paddedAmount
        let swapData = makeSwapData(
            walletAddress: TestValues.ethereumSender,
            to: TestValues.ethereumAggregator,
            data: callData
        )
        let input = makeSwapInput(
            from: fromAsset,
            to: toAsset,
            swapData: swapData,
            useMaxAmount: false,
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

        #expect(result == [mockSigner.tokenTransferResult])
        #expect(mockSigner.transferInputs.isEmpty)
        #expect(mockSigner.tokenTransferInputs.count == 1)

        guard let captured = mockSigner.tokenTransferInputs.first else {
            #expect(Bool(false))
            return
        }

        #expect(captured.asset == fromAsset)
        if case .transfer(let asset) = captured.type {
            #expect(asset == fromAsset)
        } else {
            #expect(Bool(false))
        }
        #expect(captured.memo == nil)
        #expect(captured.useMaxAmount == false)
        #expect(captured.value == swapData.quote.fromValueBigInt)

        let callDataBytes = try #require(Data(fromHex: callData))
        let addressData = callDataBytes.subdata(in: 4 ..< 36).suffix(20)
        let expectedDestination = addressData.hexString.append0x

        #expect(captured.destinationAddress == expectedDestination)
        #expect(captured.destinationAddress != swapData.data.to)
    }

    @Test
    func trc20TransferSwapUsesTokenTransferAndParsesBase58Destination() throws {
        let fromAsset = Asset(
            id: AssetId(chain: .tron, tokenId: TestValues.tronTokenId),
            name: "Tether USD",
            symbol: "USDT",
            decimals: 6,
            type: .trc20
        )
        let toAsset = Asset(
            id: AssetId(chain: .near, tokenId: nil),
            name: "NEAR",
            symbol: "NEAR",
            decimals: 24,
            type: .native
        )
        let functionSelector = "a9059cbb"
        let paddedDestination = TestValues.tronDestinationHex.addPadding(number: 64, padding: "0")
        let paddedAmount = String(repeating: "0", count: 63) + "1"
        let callData = "0x" + functionSelector + paddedDestination + paddedAmount
        let swapData = makeSwapData(
            walletAddress: TestValues.tronSender,
            to: TestValues.tronAggregator,
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

        guard let captured = mockSigner.tokenTransferInputs.first else {
            #expect(Bool(false))
            return
        }

        #expect(captured.asset == fromAsset)
        if case .transfer(let asset) = captured.type {
            #expect(asset == fromAsset)
        } else {
            #expect(Bool(false))
        }
        #expect(captured.memo == nil)
        #expect(captured.useMaxAmount == false)
        #expect(captured.value == swapData.quote.fromValueBigInt)
        #expect(captured.destinationAddress == TestValues.tronDestination)
        #expect(captured.destinationAddress != swapData.data.to)
    }

    @Test
    func nearTransferSwapKeepsMetadataAndUsesTransfer() throws {
        let fromAsset = Asset(
            id: AssetId(chain: .near, tokenId: nil),
            name: "NEAR",
            symbol: "NEAR",
            decimals: 24,
            type: .native
        )
        let toAsset = Asset(
            id: AssetId(chain: .ethereum, tokenId: nil),
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            type: .native
        )
        let swapData = makeSwapData(
            walletAddress: TestValues.nearSender,
            to: TestValues.nearReceiver,
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
        let fromAsset = Asset(
            id: AssetId(chain: .sui, tokenId: nil),
            name: "Sui",
            symbol: "SUI",
            decimals: 9,
            type: .native
        )
        let toAsset = Asset(
            id: AssetId(chain: .ethereum, tokenId: nil),
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            type: .native
        )
        let swapData = makeSwapData(
            walletAddress: TestValues.suiSender,
            to: TestValues.suiReceiver,
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
