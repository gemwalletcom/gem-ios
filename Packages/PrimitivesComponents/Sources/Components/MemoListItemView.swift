// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization

public struct MemoListItemView: View {
    private let memo: String?

    public init(memo: String?) {
        self.memo = memo
    }

    public var body: some View {
        ListItemView(
            title: Localized.Transfer.memo,
            subtitle: subtitle
        )
        .contextMenu( memo.map ({ [.copy(value: $0)] }) ?? [] )
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
