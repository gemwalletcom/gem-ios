// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapQuote
import struct Gemstone.SwapProviderType
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
    
    let state: StateViewType<Bool>
    private let availableQuotes: [SwapQuote]
    private let fromAssetPrice: SwapAssetPrice
    private let toAssetPrice: SwapAssetPrice
    private let providerViewModel: SwapProviderViewModel
    private let selectedQuote: SwapQuote
    private var rateDirection: AssetRateFormatter.Direction = .direct
    private let priceViewModel: PriceViewModel

    private let swapProviderSelectAction: ((SwapProviderItem) -> Void)?

    public init(
        state: StateViewType<Bool>? = nil,
        fromAssetPrice: SwapAssetPrice,
        toAssetPrice: SwapAssetPrice,
        selectedQuote: SwapQuote,
        availableQuotes: [SwapQuote],
        preferences: Preferences = .standard,
        swapProviderSelectAction: ((SwapProviderItem) -> Void)? = nil
    ) {
        self.state = state ?? .data(true)
        self.fromAssetPrice = fromAssetPrice
        self.toAssetPrice = toAssetPrice
        self.providerViewModel = SwapProviderViewModel(provider: selectedQuote.data.provider)
        self.selectedQuote = selectedQuote
        self.availableQuotes = availableQuotes
        self.priceViewModel = PriceViewModel(price: toAssetPrice.price, currencyCode: preferences.currency)
        self.swapProviderSelectAction = swapProviderSelectAction
    }
    
    
    // MARK: - Provider
    var providerField: String { Localized.Common.provider }
    var providerText: String { providerViewModel.providerText }
    var providerImage: AssetImage? { providerViewModel.providerImage }
    var providers: [SwapProviderItem] {
        Array(availableQuotes.prefix(3).map { quote in
            SwapProviderItem(
                asset: toAssetPrice.asset,
                swapQuote: quote,
                selectedProvider: selectedQuote.data.provider.id,
                priceViewModel: priceViewModel,
                valueFormatter: valueFormatter
            )
        })
    }
    var allowSelectProvider: Bool {
        providers.count > 1
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
         try? AssetRateFormatter().rate(
            fromAsset: fromAssetPrice.asset,
            toAsset: toAssetPrice.asset,
            fromValue: selectedQuote.fromValueBigInt,
            toValue: selectedQuote.toValueBigInt,
            direction: rateDirection
        )
    }
    
    // MARK: - Price Impact
    var priceImpactModel: PriceImpactViewModel {
        PriceImpactViewModel(
            fromAssetPrice: fromAssetPrice,
            fromValue: selectedQuote.fromValue,
            toAssetPrice: toAssetPrice,
            toValue: selectedQuote.toValue
        )
    }
    
    // MARK: - Slippage
    var slippageField: String { Localized.Swap.slippage }
    var slippageText: String {
        let slippageValue = Double(selectedQuote.request.options.slippage.bps) / 100
        return String(format: "%@ %@", "\(slippageValue.rounded(toPlaces: 2))", "%")
    }
    
    // MARK: - Actions
    func switchRateDirection() {
        switch rateDirection {
        case .direct: rateDirection = .inverse
        case .inverse: rateDirection = .direct
        }
    }

    func onFinishSwapProviderSelection(item: SwapProviderItem) {
        swapProviderSelectAction?(item)
    }
}
