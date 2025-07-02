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
    var rateDirection: AssetRateFormatter.Direction = .direct

    private let onSwap: TransferDataAction
    private let swapQuotesProvider: any SwapQuotesProvidable
    private let preferences: Preferences
    private let formatter = SwapValueFormatter(valueFormatter: .full)
    private let toValueFormatter = SwapValueFormatter(valueFormatter: ValueFormatter(style: .auto))
    private static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .short
        return formatter
    }()

    public init(
        preferences: Preferences = Preferences.standard,
        wallet: Wallet,
        asset: Asset,
        walletsService: WalletsService,
        swapQuotesProvider: SwapQuotesProvidable,
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
        self.onSwap = onSwap
    }

    var title: String { Localized.Wallet.swap }

    var swapFromTitle: String { Localized.Swap.youPay }
    var swapToTitle: String { Localized.Swap.youReceive }
    var errorTitle: String { Localized.Errors.errorOccured }

    var providerField: String { Localized.Common.provider }

    var swapEstimationTitle: String { Localized.Swap.EstimatedTime.title }
    var swapEstimationText: String? {
        guard
            let estimation = selectedSwapQuote?.etaInSeconds, estimation > 60,
            let estimationTime = Self.timeFormatter.string(from: TimeInterval(estimation))
        else {
            return nil
        }
        return String(format: "%@ %@", "≈", estimationTime)
    }

    var providerText: String? { selectedProvderModel?.providerText }
    var providerImage: AssetImage? { selectedProvderModel?.providerImage }

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
        amountInputModel.isValid == false
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
            toValue: selectedSwapQuote.toValueBigInt,
            direction: rateDirection
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
                currencyCode: preferences.currency,
                currencyFormatterType: .currency
            ),
            type: type
        )
    }
    
    func switchRateDirection() {
        switch rateDirection {
        case .direct: rateDirection = .inverse
        case .inverse: rateDirection = .direct
        }
    }

    public func swapProvidersViewModel(asset: AssetData) -> SwapProvidersViewModel {
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

    func onSelectProviderSelector() {
        guard let toAsset else { return }
        isPresentedInfoSheet = .swapProvider(toAsset)
    }

    public func onFinishSwapProvderSelection(list: [SwapProviderItem]) {
        selectedSwapQuote = list.first?.swapQuote
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
        guard let fromAsset = fromAsset,
              let toAsset = toAsset,
              let quote = selectedSwapQuote
        else {
            return
        }
        onSwap?(
            SwapTransferDataFactory.swap(
                fromAsset: fromAsset.asset,
                toAsset: toAsset.asset,
                quote: quote,
                quoteData: nil
            )
        )
    }

    private func performFetch(input: SwapQuoteInput) async {
        do {
            // reset transfer data on quotes fetch
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
