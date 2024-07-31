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

@Observable
class SwapViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(300)

    let keystore: any Keystore
    let walletService: WalletService

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

    init(
        wallet: Wallet,
        assetId: AssetId,
        walletService: WalletService,
        swapService: SwapService,
        keystore: any Keystore
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.walletService = walletService
        self.swapService = swapService

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
        !isValidFromValue(assetData: fromAssetData) || swapAvailabilityState.isLoading || swapAvailabilityState.isNoData || isApprovalProcessInProgress
    }

    func swapTokenModel(from assetData: AssetData) -> SwapTokenViewModel {
        SwapTokenViewModel(model: AssetDataViewModel(assetData: assetData, formatter: .medium))
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
            swapAvailabilityState = .noData
            return
        }

        let fromAsset = fromAssetData.asset
        swapAvailabilityState = .loading

        do {
            switch fromAsset.type {
            case .trc20, .ibc, .jetton, .synth:
                fatalError("Unsupported asset type")
            case .native, .spl, .token:
                let swapQuote = try await quote(fromAsset: fromAsset, toAsset: toAsset, amount: fromValue, includeData: false)
                await MainActor.run {
                    swapAvailabilityState = .loaded(SwapAvailabilityResult(quote: swapQuote, allowance: true))
                    toValue = formatter.string(swapQuote.toValue, decimals: toAsset.decimals.asInt)
                }
            case .bep20, .erc20:
                let swapQuote = try await quote(fromAsset: fromAsset, toAsset: toAsset, amount: fromValue, includeData: false)
                let address = try wallet.account(for: fromAsset.chain).address
                let contract = try fromAsset.getTokenId()
                let spender = try SwapService.getSpender(chain: fromAsset.chain, quote: swapQuote)
                let allowance = try await swapService.getAllowance(chain: fromAsset.chain, contract: contract, owner: address, spender: spender)
                await MainActor.run {
                    swapAvailabilityState = .loaded(SwapAvailabilityResult(quote: swapQuote, allowance: !allowance.isZero))
                    toValue = formatter.string(swapQuote.toValue, decimals: toAsset.decimals.asInt)
                }
            }
        } catch {
            await MainActor.run { [self] in
                swapAvailabilityState = .error(error)
            }
        }
    }

    func updateAssets(assetIds: [AssetId]) async throws {
        async let prices: () = try walletService.updatePrices(assetIds: assetIds)
        async let balances: () = try walletService.updateBalance(for: wallet.walletId, assetIds: assetIds)
        let _ = try await [prices, balances]
    }

    func swap(fromAsset: Asset, toAsset: Asset) async {
        guard case .loaded(let swapAvailability) = swapAvailabilityState else {
            return
        }
        do {
            if swapAvailability.allowance {
                transferData = try await getSwapData(fromAsset: fromAsset, toAsset: toAsset, amount: fromValue)
                return
            }
            let spender = try SwapService.getSpender(chain: fromAsset.chain, quote: swapAvailability.quote)

            try await MainActor.run { [self] in
                transferData = try getSwapDataOnApprove(fromAsset: fromAsset, toAsset: toAsset, spender: spender, spenderName: swapAvailability.quote.provider.name)
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

        return amount > 0 && amount <= assetData.balance.available
    }

    private func getSwapDataOnApprove(fromAsset: Asset, toAsset: Asset, spender: String, spenderName: String) throws -> TransferData {
        let transferDataType: TransferDataType = .swap(fromAsset, toAsset, SwapAction.approval(spender: spender, allowance: .MAX_256))
        let recipientData = RecipientData(asset: fromAsset,
                                          recipient: Recipient(name: spenderName, address: try fromAsset.getTokenId(),
                                                               memo: .none))

        return TransferData(type: transferDataType, recipientData: recipientData, value: BigInt.zero)
    }

    private func getSwapData(fromAsset: Asset, toAsset: Asset, amount: String) async throws -> TransferData {
        let quote = try await self.quote(fromAsset: fromAsset, toAsset: toAsset, amount: amount, includeData: true)
        guard let data = quote.data else {
            throw SwapError.noQuoteData
        }

        let amount = try formatter.inputNumber(from: amount, decimals: Int(fromAsset.decimals))
        let swapData = SwapData(quote: quote)
        let transferDataType: TransferDataType = .swap(fromAsset, toAsset, .swap(swapData))
        let recepientData = RecipientData(asset: fromAsset,
                                          recipient: Recipient(name: quote.provider.name, address: data.to, memo: .none))

        return TransferData(type: transferDataType, recipientData: recepientData, value: amount)
    }

    private func quote(fromAsset: Asset, toAsset: Asset, amount: String, includeData: Bool) async throws -> SwapQuote {
        let request = try createRequest(fromAsset, toAsset, amount, includeData: includeData)
        return try await swapService.getQuote(request: request).quote
    }

    private func createRequest(_ fromAsset: Asset, _ toAsset: Asset, _ amount: String, includeData: Bool) throws -> SwapQuoteRequest {
        let amount = try formatter.inputNumber(from: amount, decimals: Int(fromAsset.decimals))
        let walletAddress = try wallet.account(for: fromAsset.chain).address
        let destinationAddress = try wallet.account(for: toAsset.chain).address

        return SwapQuoteRequest(
            fromAsset: fromAsset.id.identifier,
            toAsset: toAsset.id.identifier,
            walletAddress: walletAddress,
            destinationAddress: destinationAddress,
            amount: amount.description,
            includeData: includeData
        )
    }
}
