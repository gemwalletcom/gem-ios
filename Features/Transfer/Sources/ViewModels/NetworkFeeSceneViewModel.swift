// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

public struct NetworkFeeSceneViewModel {
    private let chain: Chain

    private var feeRates: [FeeRate] = []

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
        case .ethereum: EVMChain(rawValue: chain.rawValue) != nil
        case .near: false
        case .sui: false
        case .tron: false
        case .xrp: false
        case .solana: false
        case .ton: false
        }
    }
}

// MARK: - Business Logic

extension NetworkFeeSceneViewModel {
    public mutating func update(rates: [FeeRate], value: String?, fiatValue: String?) {
        self.feeRates = rates
        self.value = value
        self.fiatValue = fiatValue
    }

    public mutating func clean() {
        self.value = nil
        self.fiatValue = nil
    }
}

// MARK: - FeePriority+Rank

extension FeePriority {
    var rank: Int {
        switch self {
        case .slow: 3
        case .normal: 2
        case .fast: 1
        }
    }
}
