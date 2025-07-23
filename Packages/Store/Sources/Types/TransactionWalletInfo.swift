// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Primitives

public struct WalletTransactionInfo: FetchableRecord, Decodable {
    public var transaction: TransactionRecord
    public var wallet: WalletRecord

    var transactionWallet: TransactionWallet {
        TransactionWallet(
            transaction: transaction.mapToTransaction(),
            wallet: wallet.mapToWallet()
        )
    }
}
