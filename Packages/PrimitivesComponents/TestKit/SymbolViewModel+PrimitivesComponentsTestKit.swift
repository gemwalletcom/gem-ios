// Copyright (c). Gem Wallet. All rights reserved.

@testable import PrimitivesComponents

public extension SymbolViewModel {
    static func mock(symbol: String = "BTC") -> SymbolViewModel {
        SymbolViewModel(symbol: symbol)
    }
}