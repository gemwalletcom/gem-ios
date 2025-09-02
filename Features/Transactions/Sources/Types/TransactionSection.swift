// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import PrimitivesComponents

public enum TransactionSectionType: String, Identifiable, Equatable {
    case header
    case swapAction
    case details
    case explorer
    
    public var id: String { rawValue }
}

public enum TransactionItem: Identifiable, Equatable, Sendable {
    case header
    case swapButton
    case date
    case status
    case participant
    case memo
    case network
    case provider
    case fee
    case explorerLink
    
    public var id: Self { self }
}

// MARK: - Item Models

public enum TransactionItemModel {
    case header(TransactionHeaderItemModel)
    case swapButton(TransactionSwapButtonItemModel)
    case date(TransactionDateItemModel)
    case status(TransactionStatusItemModel)
    case participant(TransactionParticipantItemModel)
    case memo(TransactionMemoItemModel)
    case network(TransactionNetworkItemModel)
    case provider(TransactionProviderItemModel)
    case fee(TransactionNetworkFeeItemModel)
    case explorer(TransactionExplorerItemModel)
}

// MARK: - Convenience Initializers

extension ListSection where T == TransactionItem {
    init(type: TransactionSectionType, _ items: [TransactionItem]) {
        self.init(type: type, values: items)
    }
}
