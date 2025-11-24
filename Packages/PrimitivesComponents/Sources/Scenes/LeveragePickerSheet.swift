// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct LeveragePickerSheet: View {
    private let title: String
    private let leverageOptions: [LeverageOption]
    @Binding var selectedLeverage: LeverageOption

    public init(title: String, leverageOptions: [LeverageOption], selectedLeverage: Binding<LeverageOption>) {
        self.title = title
        self.leverageOptions = leverageOptions
        _selectedLeverage = selectedLeverage
    }

    public var body: some View {
        NavigationStack {
            LeveragePickerView(
                leverageOptions: leverageOptions,
                selectedLeverage: $selectedLeverage
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarDismissItem(
                    title: .done,
                    placement: .topBarLeading
                )
            }
        }
        .presentationDetents([.height(300)])
    }
}
