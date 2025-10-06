// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Formatters
import Foundation
import Localization
import Primitives
import PrimitivesComponents

public struct TransactionSizeViewModel: Sendable {
    private let transaction: TransactionExtended

    public init(transaction: TransactionExtended) {
        self.transaction = transaction
    }
}

extension TransactionSizeViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
//        guard case .perpetual = transaction.transaction.metadata,
//              !transaction.transaction.value.isEmpty,
//              let value = BigInt(transaction.transaction.value)
//        else {
//            return .empty
//        }
        //TODO Implement later
        return .empty
//        let formatter = ValueFormatter.short
//        let formattedValue = formatter.string(
//            BigInt(transaction.transaction.value)!,
//            decimals: transaction.asset.decimals.asInt,
//            currency: transaction.asset.symbol
//        )
//
//        return .size(
//            title: Localized.Perpetual.size,
//            value: formattedValue
//        )
    }
}
