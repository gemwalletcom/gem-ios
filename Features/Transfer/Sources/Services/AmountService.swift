// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceService
import BalanceService
import StakeService

public struct AmountService {
    private let priceService: PriceService
    private let balanceService: BalanceService
    private let stakeService: StakeService

    public init(
        priceService: PriceService,
        balanceService: BalanceService,
        stakeService: StakeService
    ) {
        self.priceService = priceService
        self.balanceService = balanceService
        self.stakeService = stakeService
    }
    
    public func getPrice(for assetId: AssetId) throws -> AssetPrice? {
        try priceService.getPrice(for: assetId)
    }
    
    public func getBalance(walletId: WalletId, assetId: String) throws -> Balance? {
        try balanceService.getBalance(walletId: walletId.id, assetId: assetId)
    }
    
    public func getRecipientAddress(chain: StakeChain?, type: AmountType, validatorId: String?) -> String? {
        stakeService.getRecipientAddress(chain: chain, type: type, validatorId: validatorId)
    }
}
