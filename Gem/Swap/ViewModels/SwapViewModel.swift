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
import Signer
import GemstonePrimitives

import struct Gemstone.SwapQuoteRequest
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData
import struct Gemstone.PermitSingle
import struct Gemstone.Permit2Data
import struct Gemstone.Permit2Detail
import func Gemstone.permit2DataToEip712Json
import class Swap.SwapPairSelectorViewModel
import struct Swap.SwapAvailabilityResult
import struct Swap.ErrorWrapper

typealias SelectAssetSwapTypeAction = ((SelectAssetSwapType) -> Void)?

@Observable
class SwapViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(150)

    let keystore: any Keystore
    let walletsService: WalletsService

    let wallet: Wallet

    var fromAssetRequest: AssetRequestOptional
    var toAssetRequest: AssetRequestOptional
    var tokenApprovalsRequest: TransactionsRequest

    var pairSelectorModel: SwapPairSelectorViewModel
    
    var fromValue: String = ""
    var toValue: String = ""
    
    var swapAvailabilityState: StateViewType<SwapAvailabilityResult> = .noData
    var swapGetQuoteDataState: StateViewType<Bool> = .noData

    private let swapService: SwapService
    private let formatter = ValueFormatter(style: .full)
    
    private let onComplete: VoidAction
    private let onSelectAsset: SelectAssetSwapTypeAction
    private let onTransferAction: TransferDataAction
    
    init(
        wallet: Wallet,
        pairSelectorModel: SwapPairSelectorViewModel,
        walletsService: WalletsService,
        swapService: SwapService,
        keystore: any Keystore,
        onSelectAsset: SelectAssetSwapTypeAction,
        onTransferAction: TransferDataAction,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.pairSelectorModel = pairSelectorModel
        self.keystore = keystore
        self.walletsService = walletsService
        self.swapService = swapService
        self.onSelectAsset = onSelectAsset
        self.onTransferAction = onTransferAction
        self.onComplete = onComplete
        
        fromAssetRequest = AssetRequestOptional(walletId: wallet.walletId.id, assetId: pairSelectorModel.fromAssetId?.identifier)
        toAssetRequest = AssetRequestOptional(walletId: wallet.walletId.id, assetId: pairSelectorModel.toAssetId?.identifier)
    
        let assetsIds = [pairSelectorModel.fromAssetId, pairSelectorModel.toAssetId]
        
        tokenApprovalsRequest = TransactionsRequest(
            walletId: wallet.walletId.id,
            type: .assetsTransactionType(assetIds: assetsIds.compactMap { $0 }, type: .tokenApproval, states: [.pending]),
            limit: 2
        )
    }

    var title: String { Localized.Wallet.swap }

    var swapFromTitle: String { Localized.Swap.youPay }
    var swapToTitle: String { Localized.Swap.youReceive }
    var errorTitle: String { Localized.Errors.errorOccured }

    var priceImpact: String { Localized.Swap.priceImpact }
    var priceImpactValue: String? {
        switch swapAvailabilityState {
        case .loaded(_): return .none //return "1%"
        default: return .none
        }
    }
    
    var actionButtonState: StateViewType<SwapAvailabilityResult> {
        switch swapGetQuoteDataState {
        case .loading: return .loading
        case .error(let error): return .error(error)
        case .noData, .loaded:
            return swapAvailabilityState
        }
    }
    
    var isSwitchAssetButtonDisabled: Bool {
        swapAvailabilityState.isLoading || swapGetQuoteDataState.isLoading
    }
    
    var isQuoteLoading: Bool {
        swapAvailabilityState.isLoading
    }
    
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
            return result.allowance ? nil : Images.System.lock
        }
        return nil
    }

    func shouldDisableActionButton(fromAssetData: AssetData, isApprovalProcessInProgress: Bool) -> Bool {
        !isValidFromValue(assetData: fromAssetData) || isApprovalProcessInProgress
    }

    func swapTokenModel(from assetData: AssetData, type: SelectAssetSwapType) -> SwapTokenViewModel {
        SwapTokenViewModel(
            model: AssetDataViewModel(assetData: assetData, formatter: .medium),
            type: type
        )
    }
    
    func onCompleteAction() {
        onComplete?()
    }
    
    func onSelectAssetAction(type: SelectAssetSwapType) {
        onSelectAsset?(type)
    }
}

// MARK: - Business Logic

extension SwapViewModel {
    func resetValues() {
        resetToValue()
        fromValue = ""
    }
    
    func resetToValue() {
        toValue = ""
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
                let value = try BigInt.from(string: swapQuote.toValue)
                await MainActor.run {
                    swapAvailabilityState = .loaded(SwapAvailabilityResult(quote: swapQuote, allowance: true))
                    toValue = formatter.string(value, decimals: toAsset.decimals.asInt)
                }
            case .bep20, .erc20:
                let swapQuote = try await getQuote(fromAsset: fromAsset, toAsset: toAsset, amount: fromValue)
                let allowance = switch swapQuote.approval {
                    case .approve: false
                    case .none, .permit2: true
                }
                let value = try BigInt.from(string: swapQuote.toValue)
                
                await MainActor.run {
                    swapAvailabilityState = .loaded(SwapAvailabilityResult(quote: swapQuote, allowance: allowance))
                    toValue = formatter.string(value, decimals: toAsset.decimals.asInt)
                }
            }
        } catch {
            await MainActor.run { [self] in
                if !error.isCancelled {
                    self.swapAvailabilityState = .error(ErrorWrapper(error))
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
                swapGetQuoteDataState = .loading
                let data = try await getSwapData(
                    fromAsset: fromAsset,
                    toAsset: toAsset,
                    quote: swapAvailability.quote
                )
                swapGetQuoteDataState = .noData
                onTransfer(data: data)
                return
            } else {
                switch swapAvailability.quote.approval {
                case .approve(let data):
                    try await MainActor.run { [self] in
                        let data = try getSwapDataOnApprove(
                            fromAsset: fromAsset,
                            toAsset: toAsset,
                            spender: data.spender,
                            spenderName: swapAvailability.quote.data.provider.name
                        )
                        onTransfer(data: data)
                    }
                case .permit2, .none:
                    break
                }
            }
        } catch {
            swapGetQuoteDataState = .error(ErrorWrapper(error))
            swapAvailabilityState = .error(ErrorWrapper(error))
        }
    }
    
    func onTransfer(data: TransferData) {
        onTransferAction?(data)
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
            recipient: Recipient(name: spenderName, address: try fromAsset.getTokenId(), memo: .none),
            amount: .none
        )

        return TransferData(
            type: transferDataType,
            recipientData: recipientData,
            value: BigInt.zero,
            canChangeValue: false,
            ignoreValueCheck: true
        )
    }

    private func getSwapData(fromAsset: Asset, toAsset: Asset, quote: SwapQuote) async throws -> TransferData {
        let quoteData = try await getQuoteData(quote: quote)
        let transferDataType: TransferDataType = .swap(fromAsset, toAsset, .swap(quote, quoteData))
        let value = BigInt(stringLiteral: quote.request.value)
        let recepientData = RecipientData(
            asset: fromAsset,
            recipient: Recipient(name: quote.data.provider.name, address: quoteData.to, memo: .none),
            amount: .none
        )
        return TransferData(type: transferDataType, recipientData: recepientData, value: value, canChangeValue: true)
    }
    
    private func getQuote(fromAsset: Asset, toAsset: Asset, amount: String) async throws -> SwapQuote {
        let value = try formatter.inputNumber(from: amount, decimals: Int(fromAsset.decimals))
        let walletAddress = try wallet.account(for: toAsset.chain).address
        let quotes = try await swapService.getQuotes(
            fromAsset: fromAsset.id,
            toAsset: toAsset.id,
            value: value.description,
            walletAddress: walletAddress
        ).sorted {
            try BigInt.from(string: $0.toValue) > BigInt.from(string: $1.toValue)
        }
        
        guard let quote = quotes.first else {
            throw AnyError("No quotes")
        }
        
        return quote
    }
    
    private func getQuoteData(quote: SwapQuote) async throws -> SwapQuoteData {
        switch quote.approval {
        case .approve, .none:
            return try await self.swapService.getQuoteData(quote, data: .none)
        case .permit2(let data):
            let chain = try AssetId(id: quote.request.fromAsset).chain
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
            let signatureData = try Data.from(hex: signature)
            let permitData = Permit2Data(permitSingle: permit2Single, signature: signatureData)
            
            return try await self.swapService.getQuoteData(quote, data: .permit2(permitData))
        }
    }
    
    public func permit2Single(token: String, spender: String, value: String, nonce: UInt64) -> Gemstone.PermitSingle {
        return PermitSingle(
            details: Permit2Detail(
                token: token,
                amount: value,
                expiration: UInt64(Date().timeIntervalSince1970) + 60 * 60 * 30,
                nonce: nonce
            ),
            spender: spender,
            sigDeadline: UInt64(Date().timeIntervalSince1970) + 60 * 30
        )
    }
}
