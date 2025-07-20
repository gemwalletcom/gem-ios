// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperQuote
import Localization
import Primitives
import Formatters
import PrimitivesComponents
import Components
import InfoSheet
import Preferences

@Observable
public final class SwapDetailsViewModel {
    
    private static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .short
        return formatter
    }()
    private let valueFormatter = ValueFormatter(style: .auto)
    private let rateFormatter = AssetRateFormatter()
    
    let state: StateViewType<[SwapperQuote]>
    private let fromAssetPrice: AssetPriceValue
    private let toAssetPrice: AssetPriceValue
    private let providerViewModel: SwapProviderViewModel
    private var selectedQuote: SwapQuote
    private var rateDirection: AssetRateFormatter.Direction = .direct
    private let priceViewModel: PriceViewModel
    private let swapProviderSelectAction: ((SwapperQuote) -> Void)?
    
    var isPresentingInfoSheet: InfoSheetType?
    var isPresentingSwapProviderSelectionSheet: Bool = false

    public init(
        state: StateViewType<[SwapperQuote]>? = nil,
        fromAssetPrice: AssetPriceValue,
        toAssetPrice: AssetPriceValue,
        selectedQuote: SwapQuote,
        preferences: Preferences = .standard,
        swapProviderSelectAction: ((SwapperQuote) -> Void)? = nil
    ) {
        self.state = state ?? .data([])
        self.fromAssetPrice = fromAssetPrice
        self.toAssetPrice = toAssetPrice
        self.providerViewModel = SwapProviderViewModel(providerData: selectedQuote.providerData)
        self.selectedQuote = selectedQuote
        self.priceViewModel = PriceViewModel(price: toAssetPrice.price, currencyCode: preferences.currency)
        self.swapProviderSelectAction = swapProviderSelectAction
    }
    
    
    // MARK: - Provider
    var providerText: String { providerViewModel.providerText }
    var providerImage: AssetImage { providerViewModel.providerImage }
    var selectedProviderItem: SwapProviderItem {
        SwapProviderItem(
            asset: toAssetPrice.asset,
            swapQuote: selectedQuote,
            selectedProvider: nil,
            priceViewModel: priceViewModel,
            valueFormatter: valueFormatter
        )
    }

    var allowSelectProvider: Bool { state.value.or([]).count > 1 }
    var swapProvidersViewModel: SwapProvidersViewModel {
        SwapProvidersViewModel(state: state.map { .plain(swapProviderItems($0)) })
    }
    
    // MARK: - Estimation
    var swapEstimationTitle: String { Localized.Swap.EstimatedTime.title }
    var swapEstimationText: String? {
        guard
            let estimation = selectedQuote.etaInSeconds, estimation > 60,
            let estimationTime = Self.timeFormatter.string(from: TimeInterval(estimation))
        else {
            return nil
        }
        return String(format: "%@ %@", "≈", estimationTime)
    }
    
    // MARK: - Rate
    var rateTitle: String { Localized.Buy.rate }
    var rateText: String? {
         try? rateFormatter.rate(
            fromAsset: fromAssetPrice.asset,
            toAsset: toAssetPrice.asset,
            fromValue: selectedQuote.fromValueBigInt,
            toValue: selectedQuote.toValueBigInt,
            direction: rateDirection
        )
    }
    
    // MARK: - Price Impact
    var highImpactWarningTitle: String {
        priceImpactModel.highImpactWarningTitle
    }
    var priceImpactModel: PriceImpactViewModel {
        PriceImpactViewModel(
            fromAssetPrice: fromAssetPrice,
            fromValue: selectedQuote.fromValue,
            toAssetPrice: toAssetPrice,
            toValue: selectedQuote.toValue
        )
    }
    var shouldShowPriceImpactInDetails: Bool {
        switch priceImpactModel.value?.type {
        case .low, .positive, nil: false
        case .medium, .high: true
        }
    }
    var priceImpactValue: String? {
        guard let value = priceImpactModel.value?.value else { return nil }
        return " (\(value))"
    }
    
    // MARK: - Slippage
    var slippageField: String { Localized.Swap.slippage }
    var slippageText: String {
        let slippageValue = Double(selectedQuote.slippageBps) / 100
        return String(format: "%@ %@", "\(slippageValue.rounded(toPlaces: 2))", "%")
    }

    // MARK: - Private methods
    private func swapProviderItems(_ quotes: [SwapperQuote]) -> [SwapProviderItem] {
        quotes.compactMap {
            SwapProviderItem(
                asset: toAssetPrice.asset,
                swapperQuote: $0,
                selectedProvider: selectedQuote.providerData.provider,
                priceViewModel: priceViewModel,
                valueFormatter: valueFormatter
            )
        }
    }
}

// MARK: - Actions
extension SwapDetailsViewModel {
    func switchRateDirection() {
        switch rateDirection {
        case .direct: rateDirection = .inverse
        case .inverse: rateDirection = .direct
        }
    }

    func onFinishSwapProviderSelection(item: [SwapProviderItem]) {
        guard let quote = item.first?.swapperQuote else { return }
        swapProviderSelectAction?(quote)
        selectedQuote = quote.asPrimitive
        isPresentingSwapProviderSelectionSheet = false
    }
    
    func onSelectPriceImpactInfoSheet() {
        isPresentingInfoSheet = .priceImpact
    }
    
    func onSelectSlippageInfoSheet() {
        isPresentingInfoSheet = .slippage
    }
    
    func onSelectProvidersSelection() {
        isPresentingSwapProviderSelectionSheet = true
    }
}
