// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization

public struct TransactionMemoViewModel: Sendable {
    private let transaction: Transaction
    
    public init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    private var showMemo: Bool {
        transaction.memo?.isEmpty == false
    }
    
    private var formattedMemo: String {
        let value = transaction.memo ?? ""
        return value.isEmpty ? "-" : value
    }
    
    public var itemModel: TransactionMemoItemModel? {
        guard showMemo else {
            return nil
        }
        
        return TransactionMemoItemModel(
            title: Localized.Transfer.memo,
            subtitle: formattedMemo
        )
    }
}