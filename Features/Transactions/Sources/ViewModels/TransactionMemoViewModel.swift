// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components

public struct TransactionMemoViewModel: Sendable {
    private let transaction: Transaction
    
    public init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    public var itemModel: TransactionItemModel {
        guard showMemo else {
            return .empty
        }

        return .listItem(
            .text(
                title: Localized.Transfer.memo,
                subtitle: formattedMemo
            )
        )
    }
}

// MARK: - Private

extension TransactionMemoViewModel {
    private var showMemo: Bool {
        transaction.memo?.isEmpty == false
    }

    private var formattedMemo: String {
        let value = transaction.memo ?? ""
        return value.isEmpty ? "-" : value
    }
}
