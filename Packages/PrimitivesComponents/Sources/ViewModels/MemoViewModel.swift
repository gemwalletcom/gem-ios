// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Localization

public struct MemoViewModel {
    private let memo: String?
    private let title: String

    public init(
        memo: String?,
        title: String = Localized.Transfer.memo
    ) {
        self.memo = memo
        self.title = title
    }

    public var formattedMemo: String {
        let value = memo ?? ""
        return value.isEmpty ? "-" : value
    }

    public var listItemModel: ListItemModel {
        .text(
            title: title,
            subtitle: formattedMemo
        )
    }
}