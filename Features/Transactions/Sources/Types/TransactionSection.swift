// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
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

public enum TransactionItemModel {
    case listItem(ListItemModel)
    case header(TransactionHeaderItemModel)
    case participant(TransactionParticipantItemModel)
    case network(title: String, subtitle: String, image: AssetImage)
    case explorer(url: URL, text: String)
    case swapAgain(text: String)
    case empty
}

public extension ListSection where T == TransactionItem {
    init(type: TransactionSectionType, _ items: [TransactionItem]) {
        self.init(type: type, values: items)
    }
}
