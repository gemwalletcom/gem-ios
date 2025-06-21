// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Keystore
import Primitives
import Signer
import SwapService

import class Gemstone.Config
import struct Gemstone.Permit2ApprovalData
import struct Gemstone.Permit2Data
import func Gemstone.permit2DataToEip712Json
import struct Gemstone.Permit2Detail
import struct Gemstone.PermitSingle
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData

public protocol SwapDataProviding: Sendable {
    func fetchQuotes(wallet: Wallet, fromAsset: Asset, toAsset: Asset, amount: BigInt) async throws -> [SwapQuote]
    func fetchQuoteData(wallet: Wallet, quote: SwapQuote) async throws -> SwapQuoteData
    func fetchSwapData(wallet: Wallet, fromAsset: Asset, toAsset: Asset, quote: SwapQuote) async throws -> TransferData
}

public struct SwapDataProvider: SwapDataProviding {
    private let keystore: any Keystore
    private let swapService: SwapService

    init(keystore: any Keystore, swapService: SwapService) {
        self.keystore = keystore
        self.swapService = swapService
    }

    public func fetchQuotes(wallet: Wallet, fromAsset: Asset, toAsset: Asset, amount: BigInt) async throws -> [SwapQuote] {
        let walletAddress = try wallet.account(for: fromAsset.chain).address
        let destinationAddress = try wallet.account(for: toAsset.chain).address
        let quotes = try await swapService.getQuotes(
            fromAsset: fromAsset,
            toAsset: toAsset,
            value: amount.description,
            walletAddress: walletAddress,
            destinationAddress: destinationAddress
        )
        return try quotes.sorted { try BigInt.from(string: $0.toValue) > BigInt.from(string: $1.toValue) }
    }

    public func fetchQuoteData(wallet: Wallet, quote: SwapQuote) async throws -> SwapQuoteData {
        switch try await swapService.getPermit2Approval(quote: quote) {
        case .none:
            return try await swapService.getQuoteData(quote, data: .none)
        case .some(let data):
            let chain = try AssetId(id: quote.request.fromAsset.id).chain
            let permitData = try permitData(wallet: wallet, chain: chain, data: data)
            return try await swapService.getQuoteData(quote, data: .permit2(permitData))
        }
    }

    public func fetchSwapData(wallet: Wallet, fromAsset: Asset, toAsset: Asset, quote: SwapQuote) async throws -> TransferData {
        let quoteData = try await fetchQuoteData(wallet: wallet, quote: quote)
        let value = BigInt(stringLiteral: quote.request.value)
        let recipientData = RecipientData(
            recipient: Recipient(name: quote.data.provider.name, address: quoteData.to, memo: .none),
            amount: .none
        )
        return TransferData(
            type: .swap(fromAsset, toAsset, quote, quoteData),
            recipientData: recipientData,
            value: value,
            canChangeValue: true
        )
    }
}

// MARK: - Private

extension SwapDataProvider {
    private func permitData(wallet: Wallet, chain: Chain, data: Permit2ApprovalData) throws -> Permit2Data {
        let permit2Single = permit2Single(
            token: data.token,
            spender: data.spender,
            value: data.value,
            nonce: data.permit2Nonce
        )
        let permit2JSON = try Gemstone.permit2DataToEip712Json(
            chain: chain.rawValue,
            data: permit2Single,
            contract: data.permit2Contract
        )
        let signer = Signer(wallet: wallet, keystore: keystore)
        let signature = try signer.signMessage(
            chain: chain,
            message: .typed(permit2JSON)
        )
        return try Permit2Data(
            permitSingle: permit2Single,
            signature: Data.from(hex: signature)
        )
    }

    private func permit2Single(token: String, spender: String, value: String, nonce: UInt64) -> Gemstone.PermitSingle {
        let config = Config.shared.getSwapConfig()
        let now = Date().timeIntervalSince1970
        return PermitSingle(
            details: Permit2Detail(
                token: token,
                amount: value,
                expiration: UInt64(now) + config.permit2Expiration,
                nonce: nonce
            ),
            spender: spender,
            sigDeadline: UInt64(now) + config.permit2SigDeadline
        )
    }
}
