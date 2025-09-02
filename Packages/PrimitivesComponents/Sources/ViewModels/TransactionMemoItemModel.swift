// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Localization

public struct TransactionMemoItemModel: ListItemViewable {
    public let memo: String?
    
    public init(memo: String?) {
        self.memo = memo
    }
    
    public var showMemo: Bool {
        memo?.isEmpty == false
    }
    
    private var formattedMemo: String {
        let value = memo ?? ""
        return value.isEmpty ? "-" : value
    }
    
    public var listItemModel: ListItemType {
        .basic(
            title: Localized.Transfer.memo,
            subtitle: formattedMemo
        )
    }
}