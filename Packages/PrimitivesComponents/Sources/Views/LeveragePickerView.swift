// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct LeveragePickerView: View {
    private let leverageOptions: [LeverageOption]
    @Binding private var selectedLeverage: LeverageOption

    public init(leverageOptions: [LeverageOption], selectedLeverage: Binding<LeverageOption>) {
        self.leverageOptions = leverageOptions
        self._selectedLeverage = selectedLeverage
    }

    public var body: some View {
        WheelPickerView(
            options: leverageOptions,
            selection: $selectedLeverage
        )
    }
}
