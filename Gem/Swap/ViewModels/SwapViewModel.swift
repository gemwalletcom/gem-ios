// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Foundation
import GemstonePrimitives
import GRDBQuery
import Keystore
import Localization
import Primitives
import Signer
import Store
import Style
import SwapService
import SwiftUI
import Transfer
import ExplorerService
import WalletsService

import struct Gemstone.Permit2Data
import func Gemstone.permit2DataToEip712Json
import struct Gemstone.Permit2Detail
import struct Gemstone.PermitSingle
import enum Gemstone.SwapProvider
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData
import struct Gemstone.SwapQuoteRequest
import struct Swap.ErrorWrapper
import struct Swap.SwapAvailabilityResult
import class Swap.SwapPairSelectorViewModel
import class Gemstone.Config

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

    var swapState: SwapState = SwapState()

    let explorerService: any ExplorerLinkFetchable = ExplorerService.standard
    
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

    var providerField: String { Localized.Common.provider }
    var providerText: String? {
        if case .loaded(let result) = swapState.availability {
            return SwapProviderViewModel(provider: result.quote.data.provider).providerText
        }
        return .none
    }

    var providerImage: AssetImage? {
        if case .loaded(let result) = swapState.availability {
            return SwapProviderViewModel(provider: result.quote.data.provider).providerImage
        }
        return .none
    }

    var actionButtonState: StateViewType<SwapAvailabilityResult> {
        switch swapState.getQuoteData {
        case .loading: .loading
        case .error(let error): .error(error)
        case .noData, .loaded: swapState.availability
        }
    }

    var isSwitchAssetButtonDisabled: Bool {
        swapState.availability.isLoading || swapState.getQuoteData.isLoading
    }

    func showToValueLoading(isApprovalProcessInProgress: Bool) -> Bool {
        isApprovalProcessInProgress || swapState.availability.isLoading
    }

    func actionButtonTitle(fromAsset: Asset, isApprovalProcessInProgress: Bool) -> String {
        switch swapState.availability {
        case .noData, .loading:
            return Localized.Wallet.swap
        case .loaded(let result):
            return result.allowance && !isApprovalProcessInProgress ? Localized.Wallet.swap : Localized.Swap.approveToken(fromAsset.symbol)
        case .error:
            return Localized.Common.tryAgain
        }
    }

    func actionButtonInfoTitle(fromAsset: Asset, isApprovalProcessInProgress: Bool) -> String? {
        if case .loaded(let result) = swapState.availability, !isApprovalProcessInProgress {
            return result.allowance ? nil : Localized.Swap.approveTokenPermission(fromAsset.symbol)
        }
        return nil
    }

    func actionButtonImage(isApprovalProcessInProgress: Bool) -> Image? {
        if case .loaded(let result) = swapState.availability, !isApprovalProcessInProgress {
            return result.allowance ? nil : Images.System.lock
        }
        return nil
    }

    func shouldDisableActionButton(fromAsset: Asset, isApprovalProcessInProgress: Bool) -> Bool {
        !isValidValue(fromAsset: fromAsset) || isApprovalProcessInProgress
    }

    func swapTokenModel(from assetData: AssetData, type: SelectAssetSwapType) -> SwapTokenViewModel {
        SwapTokenViewModel(
            model: AssetDataViewModel(assetData: assetData, formatter: .medium),
            type: type
        )
    }

    func assetIds(_ fromAsset: AssetData?, _ toAsset: AssetData?) -> [AssetId] {
        [fromAsset?.asset.id, toAsset?.asset.id].compactMap { $0 }
    }

    func onCompleteAction() {
        onComplete?()
    }

    func onSelectAssetAction(type: SelectAssetSwapType) {
        onSelectAsset?(type)
    }
    
    func priceImpactViewModel(_ fromAsset: AssetData?, _ toAsset: AssetData?) -> PriceImpactViewModel? {
        guard
            case .loaded(let result) = swapState.availability,
            let fromAsset,
            let toAsset
        else {
            return nil
        }
        return PriceImpactViewModel(
            fromAssetData: fromAsset,
            fromValue: result.quote.fromValue,
            toAssetData: toAsset,
            toValue: result.quote.toValue
        )
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

    func onFetchStateChange(state: SwapFetchState) async {
        switch state {
        case let .fetch(input, _):
            guard let fromAsset = input.fromAsset, let toAsset = input.toAsset else { return }
            await fetch(
                fromAsset: fromAsset.asset,
                toAsset: toAsset.asset,
                amount: input.amount,
                isApprovalInProgress: input.isApprovalInProgress
            )
        case .idle: break
        }
    }

    func onAssetIdsChange(assetIds: [AssetId]) async {
        await updateAssets(assetIds: assetIds)
    }

    func swap(fromAsset: Asset, toAsset: Asset) async {
        guard case .loaded(let swapAvailability) = swapState.availability else {
            return
        }
        do {
            if swapAvailability.allowance {
                swapState.getQuoteData = .loading
                let data = try await getSwapData(
                    fromAsset: fromAsset,
                    toAsset: toAsset,
                    quote: swapAvailability.quote
                )
                swapState.getQuoteData = .noData
                onTransfer(data: data)
                return
            } else {
                switch swapAvailability.quote.approval {
                case .approve(let data):
                    try await MainActor.run { [self] in
                        let data = try getSwapDataOnApprove(
                            fromAsset: fromAsset,
                            toAsset: toAsset,
                            quote: swapAvailability.quote,
                            spender: data.spender
                        )
                        onTransfer(data: data)
                    }
                case .permit2, .none:
                    break
                }
            }
        } catch {
            swapState.getQuoteData = .error(ErrorWrapper(error))
            swapState.availability = .error(ErrorWrapper(error))
        }
    }

    func onTransfer(data: TransferData) {
        onTransferAction?(data)
    }
}

// MARK: - Private

extension SwapViewModel {
    private func isValidValue(fromAsset: Asset) -> Bool {
        guard !fromValue.isEmpty else { return false }
        let amount = (try? formatter.inputNumber(from: fromValue, decimals: Int(fromAsset.decimals))) ?? BigInt.zero

        return amount > 0
    }

    private func fetch(
        fromAsset: Asset,
        toAsset: Asset,
        amount: String,
        isApprovalInProgress: Bool
    ) async {
        let shouldFetch: Bool = await MainActor.run { [self] in
            resetToValue()
            if !self.isValidValue(fromAsset: fromAsset) || isApprovalInProgress {
                self.swapState.availability = .noData
                return false
            }
            self.swapState.availability = .loading
            return true
        }

        guard shouldFetch else { return }

        do {
            let swapQuote = try await getQuote(fromAsset: fromAsset, toAsset: toAsset, amount: amount)
            let value = try BigInt.from(string: swapQuote.toValue)
            await MainActor.run {
                swapState.availability = .loaded(SwapAvailabilityResult(quote: swapQuote, allowance: true))
                toValue = formatter.string(value, decimals: toAsset.decimals.asInt)
            }
        } catch {
            await MainActor.run { [self] in
                if !error.isCancelled {
                    self.swapState.availability = .error(ErrorWrapper(error))
                    NSLog("fetch asset data error: \(error)")
                }
            }
        }
    }

    private func updateAssets(assetIds: [AssetId]) async {
        async let prices: () = try walletsService.updatePrices(assetIds: assetIds)
        async let balances: () = try walletsService.updateBalance(for: wallet.walletId, assetIds: assetIds)

        do {
            _ = try await [prices, balances]
        } catch {
            // TODO: - handle error
            print("SwapScene updateAssets error: \(error)")
        }
    }

    private func getSwapData(fromAsset: Asset, toAsset: Asset, quote: SwapQuote) async throws -> TransferData {
        let quoteData = try await getQuoteData(quote: quote)
        let transferDataType: TransferDataType = .swap(fromAsset, toAsset, quote, quoteData)
        let value = BigInt(stringLiteral: quote.request.value)
        let recepientData = RecipientData(
            recipient: Recipient(name: quote.data.provider.name, address: quoteData.to, memo: .none),
            amount: .none
        )
        return TransferData(type: transferDataType, recipientData: recepientData, value: value, canChangeValue: true)
    }

    private func getQuote(fromAsset: Asset, toAsset: Asset, amount: String) async throws -> SwapQuote {
        let value = try formatter.inputNumber(from: amount, decimals: Int(fromAsset.decimals))
        let walletAddress = try wallet.account(for: fromAsset.chain).address
        let destinationAddress = try wallet.account(for: toAsset.chain).address
        let quotes = try await swapService.getQuotes(
            fromAsset: fromAsset.id,
            toAsset: toAsset.id,
            value: value.description,
            walletAddress: walletAddress,
            destinationAddress: destinationAddress
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
            return try await swapService.getQuoteData(quote, data: .none)
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

            return try await swapService.getQuoteData(quote, data: .permit2(permitData))
        }
    }

    public func permit2Single(token: String, spender: String, value: String, nonce: UInt64) -> Gemstone.PermitSingle {
        let config = Config.shared.getSwapConfig()
        return PermitSingle(
            details: Permit2Detail(
                token: token,
                amount: value,
                expiration: UInt64(Date().timeIntervalSince1970) + config.permit2Expiration,
                nonce: nonce
            ),
            spender: spender,
            sigDeadline: UInt64(Date().timeIntervalSince1970) + config.permit2SigDeadline
        )
    }

    public func getAssetsForPayAssetId(assetId: AssetId) -> ([Primitives.Chain], [Primitives.AssetId]) {
        swapService.supportedAssets(for: assetId)
    }
}

extension Gemstone.SwapProvider {
    var image: Image {
        switch self {
        case .uniswapV3: Images.SwapProviders.uniswap
        case .jupiter: Images.SwapProviders.jupiter
        case .orca: Images.SwapProviders.orca
        case .pancakeSwapV3, .pancakeSwapAptosV2: Images.SwapProviders.pancakeswap
        case .thorchain: Images.SwapProviders.thorchain
        case .across: Images.SwapProviders.across
        }
    }
}
