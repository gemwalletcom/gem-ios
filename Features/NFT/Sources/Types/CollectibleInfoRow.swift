// Copyright (c). Gem Wallet. All rights reserved.

import Components
import PrimitivesComponents

struct CollectibleInfoRow {
    enum Action {
        case copy(String)
        case explorer(ExplorerContextData)
    }

    let field: ListItemField
    let action: Action
}
