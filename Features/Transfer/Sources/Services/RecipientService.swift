// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import PriceService
import SwapService
import TransactionService

public struct RecipientService {
    private let balanceService: BalanceService
    private let priceService: PriceService
    private let swapService: SwapService
    private let transactionService: TransactionService

    public init(
        balanceService: BalanceService,
        priceService: PriceService,
        swapService: SwapService,
        transactionService: TransactionService
    ) {
        self.balanceService = balanceService
        self.priceService = priceService
        self.swapService = swapService
        self.transactionService = transactionService
    }
}