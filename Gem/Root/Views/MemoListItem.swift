// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import PrimitivesComponents

struct MemoListItem: View {
    
    let memo: String?
    
    var body: some View {
        ListItemView(
            title: Localized.Transfer.memo,
            subtitle: subtitle
        ).contextMenu {
            ContextMenuCopy(title: Localized.Common.copy, value: memo ?? "")
        }
    }
    
    private var subtitle: String {
        MemoFormatter.format(memo: memo)
    }
}


struct MemoFormatter {
    static func format(memo: String?) -> String {
        let value = memo ?? ""
        return value.isEmpty ? "-" : value
    }
}
