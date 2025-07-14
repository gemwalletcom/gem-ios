// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives

import struct Gemstone.SwapQuote

public protocol SwapQuoteDataProvidable: Sendable {
    func fetchQuoteData(wallet: Wallet, quote: SwapQuote) async throws -> SwapQuoteData
}

public struct SwapQuoteDataProvider: SwapQuoteDataProvidable {
    private let permit2DataProvider: Permit2DataProvidable
    private let swapService: SwapService

    public init(keystore: any Keystore, swapService: SwapService) {
        self.permit2DataProvider = Permit2DataProvider(keystore: keystore)
        self.swapService = swapService
    }

    public func fetchQuoteData(wallet: Wallet, quote: SwapQuote) async throws -> SwapQuoteData {
        switch try await swapService.getPermit2Approval(quote: quote) {
        case .none:
            return try await swapService.getQuoteData(quote, data: .none).asPrimitive
        case .some(let approval):
            let permit2Data = try permit2DataProvider.getPermit2Data(
                wallet: wallet,
                chain: try AssetId(id: quote.request.fromAsset.id).chain,
                approval: approval
            )
            return try await swapService.getQuoteData(quote, data: .permit2(permit2Data)).asPrimitive
        }
    }
}

