// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import BigInt
import Keystore
import Components
import SwiftUI
import GRDBQuery
import Style
import Localization
import Transfer
import SwapService

import struct Gemstone.SwapQuoteRequest
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData

@Observable
class SwapViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(300)

    let keystore: any Keystore
    let walletsService: WalletsService

    let wallet: Wallet

    var fromAssetRequest: AssetRequest
    var toAssetRequest: AssetRequest
    var tokenApprovalsRequest: TransactionsRequest

    var fromValue: String = ""
    var toValue: String = ""
    var transferData: TransferData?

    var swapAvailabilityState: StateViewType<SwapAvailabilityResult> = .noData

    private let swapService: SwapService
    private let formatter = ValueFormatter(style: .full)
    
    private let onComplete: VoidAction
    
    init(
        wallet: Wallet,
        assetId: AssetId,
        walletsService: WalletsService,
        swapService: SwapService,
        keystore: any Keystore,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.walletsService = walletsService
        self.swapService = swapService
        self.onComplete = onComplete
        
        // temp code
        let fromId: AssetId
        let toId: AssetId
        if assetId.type == .native {
            //TODO: Swap. Support later
            fatalError("Native swaps are not supported yet")
        } else {
            fromId = assetId.chain.assetId
            toId = assetId
        }

        fromAssetRequest = AssetRequest(walletId: wallet.walletId.id, assetId: fromId.identifier)
        toAssetRequest = AssetRequest(walletId: wallet.walletId.id, assetId: toId.identifier)
        tokenApprovalsRequest = TransactionsRequest(
            walletId: wallet.walletId.id,
            type: .assetsTransactionType(assetIds: [fromId, toId], type: .tokenApproval, states: [.pending]),
            limit: 2
        )
    }

    var title: String { Localized.Wallet.swap }

    var swapFromTitle: String { Localized.Swap.youPay }
    var swapToTitle: String { Localized.Swap.youReceive }
    var errorTitle: String { Localized.Errors.errorOccured }

    func actionButtonTitle(fromAsset: Asset, isApprovalProcessInProgress: Bool) -> String {
        switch swapAvailabilityState {
        case .noData, .loading:
            return Localized.Wallet.swap
        case .loaded(let result):
            return result.allowance && !isApprovalProcessInProgress ? Localized.Wallet.swap : Localized.Swap.approveToken(fromAsset.symbol)
        case .error:
            return Localized.Common.tryAgain
        }
    }

    func actionButtonInfoTitle(fromAsset: Asset, isApprovalProcessInProgress: Bool) -> String? {
        if case .loaded(let result) = swapAvailabilityState, !isApprovalProcessInProgress {
            return result.allowance ? nil : Localized.Swap.approveTokenPermission(fromAsset.symbol)
        }
        return nil
    }

    func actionButtonImage(isApprovalProcessInProgress: Bool) -> Image? {
        if case .loaded(let result) = swapAvailabilityState, !isApprovalProcessInProgress {
            return result.allowance ? nil : Image(systemName: SystemImage.lock)
        }
        return nil
    }

    func shouldDisableActionButton(fromAssetData: AssetData, isApprovalProcessInProgress: Bool) -> Bool {
        !isValidFromValue(assetData: fromAssetData) || isApprovalProcessInProgress
    }

    func swapTokenModel(from assetData: AssetData) -> SwapTokenViewModel {
        SwapTokenViewModel(model: AssetDataViewModel(assetData: assetData, formatter: .medium))
    }
    
    func onCompleteAction() {
        onComplete?()
    }
}

// MARK: - Business Logic

extension SwapViewModel {
    func resetValues() {
        toValue = ""
        fromValue = ""
    }

    func setMaxFromValue(asset: Asset, value: BigInt) {
        fromValue = formatter.string(value, decimals: asset.decimals.asInt)
    }

    func fetch(fromAssetData: AssetData, toAsset: Asset) async {
        guard isValidFromValue(assetData: fromAssetData) else {
            await MainActor.run {
                swapAvailabilityState = .noData
            }
            return
        }

        let fromAsset = fromAssetData.asset
        
        await MainActor.run {
            swapAvailabilityState = .loading
        }
        
        do {
            switch fromAsset.type {
            case .trc20, .ibc, .jetton, .synth:
                fatalError("Unsupported asset type")
            case .native, .spl, .token:
                let swapQuote = try await getQuote(fromAsset: fromAsset, toAsset: toAsset, amount: fromValue)
                await MainActor.run {
                    swapAvailabilityState = .loaded(SwapAvailabilityResult(quote: swapQuote, allowance: true))
                    toValue = formatter.string(BigInt(stringLiteral: swapQuote.toValue), decimals: toAsset.decimals.asInt)
                }
            case .bep20, .erc20:
                let swapQuote = try await getQuote(fromAsset: fromAsset, toAsset: toAsset, amount: fromValue)
                let allowance = switch swapQuote.approval {
                    case .approve: false
                    case .none, .permit2: true
                }
                
                await MainActor.run {
                    swapAvailabilityState = .loaded(SwapAvailabilityResult(quote: swapQuote, allowance: allowance))
                    toValue = formatter.string(BigInt(stringLiteral: swapQuote.toValue), decimals: toAsset.decimals.asInt)
                }
            }
        } catch {
            await MainActor.run { [self] in
                if !error.isCancelled {
                    self.swapAvailabilityState = .error(error)
                    NSLog("fetch asset data error: \(error)")
                }
            }
        }
    }

    func updateAssets(assetIds: [AssetId]) async throws {
        async let prices: () = try walletsService.updatePrices(assetIds: assetIds)
        async let balances: () = try walletsService.updateBalance(for: wallet.walletId, assetIds: assetIds)
        let _ = try await [prices, balances]
    }

    func swap(fromAsset: Asset, toAsset: Asset) async {
        guard case .loaded(let swapAvailability) = swapAvailabilityState else {
            return
        }
        do {
            if swapAvailability.allowance {
                transferData = try await getSwapData(
                    fromAsset: fromAsset,
                    toAsset: toAsset,
                    quote: swapAvailability.quote
                )
                return
            } else {
                switch swapAvailability.quote.approval {
                case .approve(let data):
                    try await MainActor.run { [self] in
                        transferData = try getSwapDataOnApprove(
                            fromAsset: fromAsset,
                            toAsset: toAsset,
                            spender: data.spender,
                            spenderName: swapAvailability.quote.provider.name
                        )
                    }
                case .permit2, .none:
                    break
                }
            }
        } catch {
            swapAvailabilityState = .error(error)
        }
    }
}

// MARK: - Private

extension SwapViewModel {
    private func isValidFromValue(assetData: AssetData) -> Bool {
        guard !fromValue.isEmpty else { return false }
        let asset = assetData.asset
        let amount = (try? formatter.inputNumber(from: fromValue, decimals: Int(asset.decimals))) ?? BigInt.zero

        return amount > 0
    }

    private func getSwapDataOnApprove(fromAsset: Asset, toAsset: Asset, spender: String, spenderName: String) throws -> TransferData {
        let transferDataType: TransferDataType = .swap(fromAsset, toAsset, SwapAction.approval(spender: spender, allowance: .MAX_256))
        let recipientData = RecipientData(
            asset: fromAsset,
            recipient: Recipient(name: spenderName, address: try fromAsset.getTokenId(), memo: .none), amount: .none
        )

        return TransferData(
            type: transferDataType,
            recipientData: recipientData,
            value: BigInt.zero,
            canChangeValue: false
        )
    }

    private func getSwapData(fromAsset: Asset, toAsset: Asset, quote: SwapQuote) async throws -> TransferData {
        let quoteData = try await getQuoteData(quote: quote)
        let transferDataType: TransferDataType = .swap(fromAsset, toAsset, .swap(quote, quoteData))
        let value = BigInt(stringLiteral: quote.request.amount)
        let recepientData = RecipientData(
            asset: fromAsset,
            recipient: Recipient(name: quote.provider.name, address: quoteData.to, memo: .none),
            amount: .none
        )
        return TransferData(type: transferDataType, recipientData: recepientData, value: value, canChangeValue: false)
    }
    
    private func getQuote(fromAsset: Asset, toAsset: Asset, amount: String) async throws -> SwapQuote {
        let value = try formatter.inputNumber(from: amount, decimals: Int(fromAsset.decimals))
        let walletAddress = try wallet.account(for: fromAsset.chain).address
        let quotes = try await swapService.getQuote(
            fromAsset: fromAsset.id,
            toAsset: toAsset.id,
            value: value.description,
            walletAddress: walletAddress
        )
        guard let quote = quotes.first else {
            throw AnyError("No quotes")
        }
        
        NSLog("quote approval: \(quote.approval)")
        
        return quote
    }
    
    private func getQuoteData(quote: SwapQuote) async throws -> SwapQuoteData {
        try await self.swapService.getQuoteData(quote)
    }
}
