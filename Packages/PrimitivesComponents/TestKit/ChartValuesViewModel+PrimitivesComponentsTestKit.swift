// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Formatters
import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

public extension ChartValuesViewModel {
    static func mock(
        period: ChartPeriod = .day,
        price: Price? = .mock(),
        values: ChartValues = .mock(),
        signed: Bool = false
    ) -> ChartValuesViewModel {
        ChartValuesViewModel(
            period: period,
            price: price,
            values: values,
            formatter: CurrencyFormatter(type: .currency, currencyCode: "USD"),
            signed: signed
        )
    }
}
