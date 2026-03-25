// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct ExplorerContextData: Sendable, Equatable, Hashable {
    public let copyValue: CopyValue
    public let explorerLink: BlockExplorerLink

    public init(
        copyValue: CopyValue,
        explorerLink: BlockExplorerLink
    ) {
        self.copyValue = copyValue
        self.explorerLink = explorerLink
    }
}
