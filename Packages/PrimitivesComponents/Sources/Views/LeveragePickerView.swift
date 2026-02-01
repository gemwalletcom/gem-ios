// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct LeveragePickerView: View {
    private let leverageOptions: [LeverageOption]
    @Binding private var selectedLeverage: LeverageOption

    init(leverageOptions: [LeverageOption], selectedLeverage: Binding<LeverageOption>) {
        self.leverageOptions = leverageOptions
        self._selectedLeverage = selectedLeverage
    }

    var body: some View {
        WheelPickerView(
            options: leverageOptions,
            selection: $selectedLeverage
        )
    }
}
