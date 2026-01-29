// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain

protocol FeeRateProviding: Sendable {
    func rates(for type: TransferDataType) async throws -> [FeeRate]
}

struct FeeRateService: FeeRateProviding {
    private let service: any ChainFeeRateFetchable

    init(
        service: any ChainFeeRateFetchable
    ) {
        self.service = service
    }

    func rates(for type: TransferDataType) async throws -> [FeeRate] {
        try await service.feeRates(type: type)
    }
}
