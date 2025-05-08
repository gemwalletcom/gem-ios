// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Foundation
import GemstonePrimitives
import Keystore
import Localization
import Preferences
import Primitives
import PrimitivesComponents
import Store
import Style
import Swap
import SwapService
import WalletsService
import struct Gemstone.SwapQuote

@MainActor
@Observable
public final class SwapSceneViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(150)

    let keystore: any Keystore
    let wallet: Wallet
    let walletsService: WalletsService

    // db observation requests
    var fromAssetRequest: AssetRequestOptional
    var toAssetRequest: AssetRequestOptional

    // observed from DB
    var fromAsset: AssetData?
    var toAsset: AssetData?

    // UI states
    var isPresentingPriceImpactConfirmation: String?
    var isPresentedInfoSheet: SwapSheetType?
    var pairSelectorModel: SwapPairSelectorViewModel

    var swapState: SwapState = .init()
    var selectedSwapQuote: SwapQuote?
    var fromValue: String = ""
    var toValue: String = ""
    var focusField: SwapScene.Field?

    private let provider: any SwapDataProviding
    private let preferences: Preferences
    private let swapService: SwapService
    private let formatter = SwapValueFormatter(valueFormatter: .full)

    init(
        preferences: Preferences = Preferences.standard,
        wallet: Wallet,
        pairSelectorModel: SwapPairSelectorViewModel,
        walletsService: WalletsService,
        swapService: SwapService,
        keystore: any Keystore
    ) {
        self.preferences = preferences
        self.wallet = wallet
        self.pairSelectorModel = pairSelectorModel
        self.keystore = keystore
        self.walletsService = walletsService
        self.swapService = swapService

        self.fromAssetRequest = AssetRequestOptional(
            walletId: wallet.walletId.id,
            assetId: pairSelectorModel.fromAssetId
        )
        self.toAssetRequest = AssetRequestOptional(
            walletId: wallet.walletId.id,
            assetId: pairSelectorModel.toAssetId
        )
        self.provider = SwapDataProvider(
            keystore: keystore,
            swapService: swapService
        )
    }

    var title: String { Localized.Wallet.swap }

    var swapFromTitle: String { Localized.Swap.youPay }
    var swapToTitle: String { Localized.Swap.youReceive }
    var errorTitle: String { Localized.Errors.errorOccured }

    var providerField: String { Localized.Common.provider }

    var providerText: String? { selectedProvderModel?.providerText }
    var providerImage: AssetImage? { selectedProvderModel?.providerImage }

    var actionButtonTitle: String {
        swapState.error != nil ? Localized.Common.tryAgain : Localized.Wallet.swap
    }

    var actionButtonState: StateViewType<[SwapQuote]> {
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
        guard let asset = fromAsset?.asset else { return false }
        do {
            return try formatter.format(inputValue: fromValue, decimals: asset.decimals.asInt) <= 0
        } catch {
            return true
        }
    }

    var isSwitchAssetButtonDisabled: Bool {
        swapState.isLoading
    }

    var isLoading: Bool {
        swapState.quotes.isLoading
    }

    var allowSelectProvider: Bool {
        swapState.quotes.value.or([]).count > 1
    }

    var assetIds: [AssetId] {
        [fromAsset?.asset.id, toAsset?.asset.id].compactMap { $0 }
    }

    var rateTitle: String { Localized.Buy.rate }
    var rateText: String? {
        guard let selectedSwapQuote, let fromAsset, let toAsset else { return nil }

        return try? AssetRateFormatter().rate(
            fromAsset: fromAsset.asset,
            toAsset: toAsset.asset,
            fromValue: selectedSwapQuote.fromValueBigInt,
            toValue: selectedSwapQuote.toValueBigInt
        )
    }

    var priceImpactModel: PriceImpactViewModel? {
        guard let selectedSwapQuote, let fromAsset, let toAsset else { return nil }
        return PriceImpactViewModel(
            fromAssetData: fromAsset,
            fromValue: selectedSwapQuote.fromValue,
            toAssetData: toAsset,
            toValue: selectedSwapQuote.toValue
        )
    }

    func swapTokenModel(type: SelectAssetSwapType) -> SwapTokenViewModel? {
        guard let assetData: AssetData = type == .pay ? fromAsset : toAsset else { return nil }
        return SwapTokenViewModel(
            model: AssetDataViewModel(
                assetData: assetData,
                formatter: .medium,
                currencyCode: preferences.currency
            ),
            type: type
        )
    }

    func swapProvidersViewModel(asset: AssetData) -> SwapProvidersViewModel {
        SwapProvidersViewModel(state: swapProvidersViewModelState(for: asset))
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
                fromValue: fromValue,
                formatter: formatter
            )
            swapState.fetch = .fetch(
                input: input,
                delay: delay
            )
        } catch {
            swapState.quotes = .noData
            swapState.swapTransferData = .noData
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

    func onChangeFromAsset(_: AssetData?, _: AssetData?) {
        resetValues()
        selectedSwapQuote = nil
        focusField = .from
        fetch()
    }

    func onChangeToAsset(_: AssetData?, _: AssetData?) {
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
            performSwap()
            return
        }

        if swapState.quotes.isError {
            fetch()
            return
        }

        if let priceImpactModel,
           let text = priceImpactModel.highImpactWarningDescription,
           priceImpactModel.showPriceImpactWarning
        {
            isPresentingPriceImpactConfirmation = text
            return
        }

        performSwap()
    }

    func onSelectSwapConfirmation() {
        performSwap()
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
        let (chains, assetIds) = swapService.supportedAssets(for: fromAsset.asset.id)
        isPresentedInfoSheet = .selectAsset(.receive(chains: chains, assetIds: assetIds))
    }

    func onSelectProviderSelector() {
        guard let toAsset else { return }
        isPresentedInfoSheet = .swapProvider(toAsset)
    }

    func onFinishSwapProvderSelection(list: [SwapProviderItem]) {
        selectedSwapQuote = list.first?.swapQuote
        isPresentedInfoSheet = nil
    }

    func onFinishAssetSelection(asset: Asset) {
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
        fromValue = ""
    }

    private func resetToValue() {
        toValue = ""
    }

    private func applyQuote(_ quote: SwapQuote, asset: Asset) {
        do {
            toValue = try formatter.format(
                quoteValue: quote.toValue,
                decimals: asset.decimals.asInt
            )
        } catch {
            NSLog("SwapScene apply quote error: \(error)")
        }
    }

    private func applyPercentToFromValue(percent: Int, assetData: AssetData) {
        fromValue = formatter.format(
            value: assetData.balance.available.multiply(byPercent: percent),
            decimals: assetData.asset.decimals.asInt
        )
    }

    public func performSwap() {
        guard let fromAsset = fromAsset,
              let toAsset = toAsset,
              let quote = selectedSwapQuote
        else {
            return
        }
        Task {
            await getFinalSwapData(
                quote: quote,
                fromAsset: fromAsset.asset,
                toAsset: toAsset.asset
            )
        }
    }

    private func performFetch(input: SwapQuoteInput) async {
        do {
            // reset transfer data on quotes fetch
            swapState.swapTransferData = .noData
            swapState.quotes = .loading
            let swapQuotes = try await provider.fetchQuotes(
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

    private func getFinalSwapData(quote: SwapQuote, fromAsset: Asset, toAsset: Asset) async  {
        do {
            swapState.swapTransferData = .loading
            let data = try await provider.fetchSwapData(
                wallet: wallet,
                fromAsset: fromAsset,
                toAsset: toAsset,
                quote: quote
            )
            swapState.swapTransferData = .data(data)
        } catch {
            if !error.isCancelled {
                swapState.swapTransferData = .error(ErrorWrapper(error))

                NSLog("SwapScene get swap data error: \(error)")
            }
        }
    }

    private func swapProvidersViewModelState(for asset: AssetData) -> StateViewType<SelectableListType<SwapProvidersViewModel.Item>> {
        switch swapState.quotes {
        case .error(let error): return .error(error)
        case .noData: return .noData
        case .data(let items):
            let priceViewModel = PriceViewModel(price: asset.price, currencyCode: preferences.currency)
            let valueFormatter = ValueFormatter(style: .short)
            return .data(.plain(
                items.map {
                    SwapProviderItem(
                        asset: asset.asset,
                        swapQuote: $0,
                        selectedProvider: selectedSwapQuote?.data.provider.id,
                        priceViewModel: priceViewModel,
                        valueFormatter: valueFormatter
                    )
                }
            ))
        case .loading: return .loading
        }
    }

    private var selectedProvderModel: SwapProviderViewModel? {
        guard let selectedSwapQuote else { return nil }
        return SwapProviderViewModel(provider: selectedSwapQuote.data.provider)
    }
}
