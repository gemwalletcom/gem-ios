// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol CurrencyUpdater: Sendable {
    func changeCurrency(for walletId: WalletId) async throws
}
