// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Primitives

struct WalletTransactionInfo: FetchableRecord, Decodable {
    var transaction: TransactionRecord
    var wallet: WalletRecord

    var transactionWallet: TransactionWallet {
        TransactionWallet(
            transaction: transaction.mapToTransaction(),
            wallet: wallet.mapToWallet()
        )
    }
}
