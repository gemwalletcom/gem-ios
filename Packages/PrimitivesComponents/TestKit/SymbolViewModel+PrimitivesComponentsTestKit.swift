// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

public extension SymbolViewModel {
    static func mock(asset: Asset = .mock()) -> SymbolViewModel {
        SymbolViewModel(asset: asset)
    }
}