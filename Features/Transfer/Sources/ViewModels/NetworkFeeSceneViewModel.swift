// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

public struct NetworkFeeSceneViewModel {
    private let chain: Chain

    public var feeRates: [FeeRate] = []
    public var feeByPriority: [FeePriority: Fee] = [:]

    public var priority: FeePriority
    public var value: String?
    public var fiatValue: String?

    public init(
        chain: Chain,
        priority: FeePriority = .normal
    ) {
        self.chain = chain
        self.priority = priority
    }

    public var title: String { Localized.Transfer.networkFee }
    public var doneTitle: String { Localized.Common.done }
    public var infoIcon: String { Localized.FeeRates.info }

    public var feeRatesViewModels: [FeeRateViewModel] {
        feeRates.map({ FeeRateViewModel(feeRate: $0, chain: chain) })
            .sorted(by: { $0.feeRate.priority.rank > $1.feeRate.priority.rank })
    }

    public var selectedFreeRateViewModel: FeeRateViewModel? {
        feeRatesViewModels.first(where: { $0.feeRate.priority == priority })
    }

    public var showFeeRatesSelector: Bool {
        isSupportedFeeRateSelection && !feeRates.isEmpty
    }

    private var isSupportedFeeRateSelection: Bool {
        switch chain.type {
        case .bitcoin: true
        case .aptos: false
        case .cosmos: false
        case .ethereum: true
        case .near: false
        case .sui: false
        case .tron: false
        case .xrp: false
        case .solana: true
        case .ton: false
        }
    }
}

// MARK: - Business Logic

extension NetworkFeeSceneViewModel {
    public mutating func set(
        rates: [FeeRate],
        feeByPriority: [FeePriority: Fee],
        value: String?,
        fiatValue: String?
    ) {
        self.feeRates = rates
        self.feeByPriority = feeByPriority
        self.update(value: value, fiatValue: fiatValue)
    }

    public mutating func update(value: String?, fiatValue: String?) {
        self.value = value
        self.fiatValue = fiatValue
    }
}
