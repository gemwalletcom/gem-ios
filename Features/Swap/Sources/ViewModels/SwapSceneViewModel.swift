// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Foundation
import GemstonePrimitives
import Localization
import Preferences
import Primitives
import PrimitivesComponents
import Store
import Style
import SwapService
import WalletsService
import enum Gemstone.SwapperError
import struct Gemstone.SwapQuote
import Formatters
import Validators

@MainActor
@Observable
public final class SwapSceneViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(150)

    public let wallet: Wallet
    public let walletsService: WalletsService

    public var swapState: SwapState = .init()
    public var isPresentedInfoSheet: SwapSheetType?

    // db observation requests
    var fromAssetRequest: AssetRequestOptional
    var toAssetRequest: AssetRequestOptional

    // observed from DB
    var fromAsset: AssetData?
    var toAsset: AssetData?

    // UI states
    var isPresentingPriceImpactConfirmation: String?
    var pairSelectorModel: SwapPairSelectorViewModel

    var selectedSwapQuote: SwapQuote?
    var amountInputModel: InputValidationViewModel = InputValidationViewModel(mode: .onDemand)
    var toValue: String = ""
    var focusField: SwapScene.Field?

    private let onSwap: TransferDataAction
    private let swapQuotesProvider: any SwapQuotesProvidable
    private let swapQuoteDataProvider: any SwapQuoteDataProvidable
    private let preferences: Preferences
    private let formatter = SwapValueFormatter(valueFormatter: .full)
    private let toValueFormatter = SwapValueFormatter(valueFormatter: ValueFormatter(style: .auto))

    public init(
        preferences: Preferences = Preferences.standard,
        wallet: Wallet,
        asset: Asset,
        walletsService: WalletsService,
        swapQuotesProvider: SwapQuotesProvidable,
        swapQuoteDataProvider: any SwapQuoteDataProvidable,
        onSwap: TransferDataAction = nil
    ) {
        let pairSelectorModel = SwapPairSelectorViewModel.defaultSwapPair(for: asset)
        self.pairSelectorModel = pairSelectorModel
        self.preferences = preferences
        self.wallet = wallet
        self.walletsService = walletsService

        self.fromAssetRequest = AssetRequestOptional(
            walletId: wallet.walletId.id,
            assetId: pairSelectorModel.fromAssetId
        )
        self.toAssetRequest = AssetRequestOptional(
            walletId: wallet.walletId.id,
            assetId: pairSelectorModel.toAssetId
        )
        self.swapQuotesProvider = swapQuotesProvider
        self.swapQuoteDataProvider = swapQuoteDataProvider
        self.onSwap = onSwap
    }

    var title: String { Localized.Wallet.swap }
    var swapFromTitle: String { Localized.Swap.youPay }
    var swapToTitle: String { Localized.Swap.youReceive }
    var errorTitle: String { Localized.Errors.errorOccured }

    public var swapDetailsViewModel: SwapDetailsViewModel? {
        guard let selectedSwapQuote, let fromAsset, let toAsset else { return nil }

        return SwapDetailsViewModel(
            state: swapState.quotes.map { _ in true },
            fromAssetPrice: AssetPriceValue(asset: fromAsset.asset, price: fromAsset.price),
            toAssetPrice: AssetPriceValue(asset: toAsset.asset, price: toAsset.price),
            selectedQuote: selectedSwapQuote,
            availableQuotes: swapState.quotes.value.or([]),
            preferences: preferences,
            swapProviderSelectAction: { [weak self] provider in
                self?.onFinishSwapProviderSelection(provider)
            }
        )
    }

    var actionButtonTitle: String {
        if amountInputModel.isValid == false, let fromAsset {
            Localized.Transfer.insufficientBalance(fromAsset.asset.symbol)
        } else {
            swapState.error != nil ? Localized.Common.tryAgain : Localized.Wallet.swap
        }
    }

    var actionButtonState: StateViewType<[SwapQuote]> {
        if let error = amountInputModel.error {
            return .error(error)
        }

        if swapState.isLoading {
            return .loading
        }

        if let error = swapState.error {
            return .error(error)
        }

        if case .data(let data) = swapState.quotes {
            return .data(data)
        }

        return swapState.quotes
    }

    var isVisibleActionButton: Bool {
        switch swapState.quotes {
        case .noData: false
        case .data, .error, .loading: true
        }
    }

    var shouldDisableActionButton: Bool {
        if amountInputModel.isValid == false {
            return true
        }
        
        if ((swapState.error as? ErrorWrapper)?.error as? RetryableError)?.isRetryAvailable == true {
            return false
        }

        return swapState.error != nil
    }

    var isSwitchAssetButtonDisabled: Bool {
        swapState.isLoading
    }
    
    var shouldShowAdditionalInfo: Bool {
        swapState.quotes.isLoading == false
    }

    var isLoading: Bool {
        swapState.quotes.isLoading
    }

    var assetIds: [AssetId] {
        [fromAsset?.asset.id, toAsset?.asset.id].compactMap { $0 }
    }

    func swapTokenModel(type: SelectAssetSwapType) -> SwapTokenViewModel? {
        guard let assetData: AssetData = type == .pay ? fromAsset : toAsset else { return nil }
        return SwapTokenViewModel(
            model: AssetDataViewModel(
                assetData: assetData,
                formatter: .medium,
                currencyCode: preferences.currency,
                currencyFormatterType: .currency
            ),
            type: type
        )
    }

}

// MARK: - Business Logic

extension SwapSceneViewModel {
    func fetch(delay: Duration? = nil) {
        do {
            resetToValue()
            let input = try SwapQuoteInput.create(
                fromAsset: fromAsset,
                toAsset: toAsset,
                fromValue: amountInputModel.text,
                formatter: formatter
            )
            swapState.fetch = .fetch(
                input: input,
                delay: delay
            )
        } catch {
            swapState.quotes = .noData
            swapState.fetch = .idle
            selectedSwapQuote = nil
        }
        
        Task {
            let assetIds =  [fromAsset?.asset.id, toAsset?.asset.id].compactMap { $0 }
            try await walletsService.addPrices(assetIds: assetIds)
        }
    }

    func onFetchStateChange(state: SwapFetchState) async {
        guard case let .fetch(input, _) = state else { return }
        await performFetch(input: input)
    }

    func onChangePair(_ _: SwapPairSelectorViewModel, _ newModel: SwapPairSelectorViewModel) {
        fromAssetRequest.assetId = newModel.fromAssetId
        toAssetRequest.assetId = newModel.toAssetId
    }

    func onChangeSwapQuoute(_ _: SwapQuote?, _ newQuote: SwapQuote?) {
        guard let newQuote, let toAsset else { return }
        applyQuote(newQuote, asset: toAsset.asset)
    }

    func onChangeFromValue(_: String, _: String) {
        fetch(delay: SwapSceneViewModel.quoteTaskDebounceTimeout)
    }

    func onChangeFromAsset(old: AssetData?, new: AssetData?) {
        guard old?.asset.id != new?.asset.id else { return }

        resetValues()
        selectedSwapQuote = nil
        focusField = .from
        fetch()
        updateValidators(for: new)
    }

    func onChangeToAsset(old: AssetData?, new: AssetData?) {
        guard old?.asset.id != new?.asset.id else { return }

        resetToValue()
        selectedSwapQuote = nil
        fetch()
    }

    func onSelectFromMaxBalance() {
        onSelectPercent(100)
    }

    func onSelectPercent(_ percent: Int) {
        guard let fromAsset else { return }
        applyPercentToFromValue(percent: percent, assetData: fromAsset)
        focusField = .none
    }

    func onSelectActionButton() {
        if swapState.swapTransferData.isError {
            swap()
            return
        }
        
        if swapState.quotes.isError {
            fetch()
            return
        }

        if let priceImpactModel = swapDetailsViewModel?.priceImpactModel,
           let text = priceImpactModel.highImpactWarningDescription,
           priceImpactModel.showPriceImpactWarning
        {
            isPresentingPriceImpactConfirmation = text
            return
        }

        swap()
    }

    func onSelectSwapConfirmation() {
        swap()
    }

    func onAssetIdsChange(assetIds: [AssetId]) async {
        await performUpdate(for: assetIds)
    }

    func onSelectPriceImpactInfo() {
        isPresentedInfoSheet = .info(.priceImpact)
    }

    func onSelectAssetPay() {
        isPresentedInfoSheet = .selectAsset(.pay)
    }

    func onSelectAssetReceive() {
        guard let fromAsset = fromAsset else { return }
        let (chains, assetIds) = swapQuotesProvider.supportedAssets(for: fromAsset.asset.id)
        isPresentedInfoSheet = .selectAsset(.receive(chains: chains, assetIds: assetIds))
    }

    func onSelectSwapDetails() {
        isPresentedInfoSheet = .swapDetails
    }

    func onFinishSwapProviderSelection(_ provider: SwapProviderItem) {
        selectedSwapQuote = provider.swapQuote
        isPresentedInfoSheet = nil
    }

    public func onFinishAssetSelection(asset: Asset) {
        guard case let .selectAsset(type) = isPresentedInfoSheet else { return }
        switch type {
        case .pay:
            if asset.id == pairSelectorModel.toAssetId {
                pairSelectorModel.toAssetId = pairSelectorModel.fromAssetId
            }
            pairSelectorModel.fromAssetId = asset.id
        case .receive:
            if asset.id == pairSelectorModel.fromAssetId {
                pairSelectorModel.fromAssetId = pairSelectorModel.toAssetId
            }
            pairSelectorModel.toAssetId = asset.id
        }
        isPresentedInfoSheet = nil
    }
}

// MARK: - Private

extension SwapSceneViewModel {
    private func resetValues() {
        resetToValue()
        amountInputModel.text = .empty
    }

    private func resetToValue() {
        toValue = ""
    }

    private func applyQuote(_ quote: SwapQuote, asset: Asset) {
        do {
            toValue = try toValueFormatter.format(
                quoteValue: quote.toValue,
                decimals: asset.decimals.asInt
            )
        } catch {
            NSLog("SwapScene apply quote error: \(error)")
        }
    }

    private func applyPercentToFromValue(percent: Int, assetData: AssetData) {
        amountInputModel.text = formatter.format(
            value: assetData.balance.available.multiply(byPercent: percent),
            decimals: assetData.asset.decimals.asInt
        )
    }

    private func swap() {
        guard let fromAsset = fromAsset, let toAsset = toAsset, let quote = selectedSwapQuote else {
            return
        }

        Task {
            do {
                swapState.swapTransferData = .loading
                let data = try await swapQuoteDataProvider.fetchQuoteData(wallet: wallet, quote: quote)
                onSwap?(
                    SwapTransferDataFactory.swap(
                        fromAsset: fromAsset.asset,
                        toAsset: toAsset.asset,
                        quote: quote,
                        quoteData: data
                    )
                )
                swapState.swapTransferData = .noData
            } catch {
                if !error.isCancelled {
                    swapState.swapTransferData = .error(ErrorWrapper(error))

                    NSLog("SwapScene get swap data error: \(error)")
                }
            }
        }
    }
    private func performFetch(input: SwapQuoteInput) async {
        do {
            // reset transfer data on quotes fetch
            swapState.swapTransferData = .noData
            swapState.quotes = .loading
            let swapQuotes = try await swapQuotesProvider.fetchQuotes(
                wallet: wallet,
                fromAsset: input.fromAsset,
                toAsset: input.toAsset,
                amount: input.amount
            )

            swapState.fetch = .data(quotes: swapQuotes)
            swapState.quotes = .data(swapQuotes)
            selectedSwapQuote = swapQuotes.first(where: { $0 == selectedSwapQuote }) ?? swapQuotes.first
            if let selectedSwapQuote, let asset = toAsset?.asset {
                applyQuote(selectedSwapQuote, asset: asset)
            }
        } catch {
            if !error.isCancelled {
                swapState.quotes = .error(ErrorWrapper(error))
                swapState.fetch = .data(quotes: [])
                selectedSwapQuote = nil

                NSLog("SwapScene get quotes error: \(error)")
            }
        }
    }

    private func performUpdate(for assetIds: [AssetId]) async {
        do {
            try await walletsService.updateAssets(
                walletId: wallet.walletId,
                assetIds: assetIds
            )
        } catch {
            // TODO: - handle error
            NSLog("SwapScene perform assets update error: \(error)")
        }
    }

    private func updateValidators(for assetData: AssetData?) {
        guard let assetData else { return }
        amountInputModel.update(
            validators: [AmountValidator.amount(
                source: .asset,
                decimals: assetData.asset.decimals.asInt,
                validators: [
                    BalanceValueValidator<BigInt>(available: assetData.balance.available, asset: assetData.asset)
                ]
            )]
        )
    }
}
