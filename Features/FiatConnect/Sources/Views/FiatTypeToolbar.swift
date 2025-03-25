// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct FiatTypeToolbar: ToolbarContent {
    @Binding private var selectedType: FiatQuoteType
    private let pickerTitleProvider: (FiatQuoteType) -> String

    init(
        selectedType: Binding<FiatQuoteType>,
        pickerTitleProvider: @escaping (FiatQuoteType) -> String
    ) {
        _selectedType = selectedType
        self.pickerTitleProvider = pickerTitleProvider
    }

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $selectedType) {
                Text(pickerTitleProvider(.buy))
                    .tag(FiatQuoteType.buy)
                Text(pickerTitleProvider(.sell))
                    .tag(FiatQuoteType.sell)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
    }
}
