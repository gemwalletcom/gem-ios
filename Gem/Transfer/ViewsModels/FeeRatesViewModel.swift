// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

struct NetworkFeeViewModel {
    let feeRates: [FeeRate]
    let selectedFeeRate: FeeRate?

    let chain: Chain
    let networkFeeValue: String?
    let networkFeeFiatValue: String?

    init(feeRates: [FeeRate], selectedFeeRate: FeeRate? = nil, chain: Chain, networkFeeValue: String?, networkFeeFiatValue: String?) {
        self.feeRates = feeRates
        self.selectedFeeRate = selectedFeeRate
        self.chain = chain
        self.networkFeeValue = networkFeeValue
        self.networkFeeFiatValue = networkFeeFiatValue
    }

    var networkFeeTitle: String { Localized.Transfer.networkFee }

    var feeRatesViewModels: [FeeRateViewModel] {
        feeRates.map({ FeeRateViewModel(feeRate: $0, chain: chain) })
            .sorted(by: { $0.feeRate.priority.rank > $1.feeRate.priority.rank })
    }

    var selectedFreeRateViewModel: FeeRateViewModel? {
        selectedFeeRate.map{ FeeRateViewModel(feeRate: $0, chain: chain)}
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
