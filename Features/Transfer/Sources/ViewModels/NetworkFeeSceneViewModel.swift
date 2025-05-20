// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Localization
import Primitives
import SwiftUI

@Observable
@MainActor
public final class NetworkFeeSceneViewModel {
    private let chain: Chain
    private var rates: [FeeRate] = []

    public var priority: FeePriority
    public var value: String?
    public var fiatValue: String?

    private let service: any ChainFeeRateFetchable

    public init(
        chain: Chain,
        priority: FeePriority,
        service: any ChainFeeRateFetchable
    ) {
        self.chain = chain
        self.priority = priority
        self.service = service
    }

    public var title: String { Localized.Transfer.networkFee }
    public var doneTitle: String { Localized.Common.done }
    public var infoIcon: String { Localized.FeeRates.info }

    public var feeRatesViewModels: [FeeRateViewModel] {
        rates.map {
            FeeRateViewModel(
                feeRate: $0,
                unitType: chain.feeUnitType,
                decimals: chain.asset.decimals.asInt,
                symbol: chain.asset.symbol
            )
        }.sorted()
    }

    public var selectedFeeRateViewModel: FeeRateViewModel? {
        feeRatesViewModels.first(where: { $0.feeRate.priority == priority })
    }

    public var showFeeRatesSelector: Bool {
        rates.count > 1
    }

    public func getFeeRates(type: TransferDataType) async throws -> [FeeRate] {
        if rates.isEmpty {
            self.rates = try await service.feeRates(type: type)
        }
        return rates
    }
}

// MARK: - Business Logic

extension NetworkFeeSceneViewModel {
    public func update(value: String?, fiatValue: String?) {
        self.value = value
        self.fiatValue = fiatValue
    }

    public func reset() {
        self.value = nil
        self.fiatValue = nil
    }
}
